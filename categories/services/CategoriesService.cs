namespace ContentReactor.Categories.Services
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading.Tasks;
    using ContentReactor.Categories.Services.Models;
    using ContentReactor.Categories.Services.Models.Data;
    using ContentReactor.Categories.Services.Models.Response;
    using ContentReactor.Categories.Services.Models.Results;
    using ContentReactor.Categories.Services.Repositories;
    using ContentReactor.Common;
    using ContentReactor.Common.Events.Audio;
    using ContentReactor.Common.EventSchemas.Categories;
    using ContentReactor.Common.EventSchemas.Images;
    using ContentReactor.Common.EventSchemas.Text;
    using ContentReactor.Common.Events;
    using Microsoft.Extensions.Localization;

    /// <summary>
    /// Service for interacting with categories.
    /// </summary>
    public class CategoriesService : ICategoriesService
    {
        /// <summary>
        /// Categories repository.
        /// </summary>
        private readonly ICategoriesRepository categoriesRepository;

        /// <summary>
        /// Service for finding an image for the category.
        /// </summary>
        private readonly IImageSearchService imageSearchService;

        /// <summary>
        /// Service for finding category synonyms.
        /// </summary>
        private readonly ISynonymService synonymService;

        /// <summary>
        /// Service for publishing events to the even grid.
        /// </summary>
        private readonly IEventGridPublisherService eventGridPublisher;

        /// <summary>
        /// Initializes a new instance of the <see cref="CategoriesService"/> class.
        /// </summary>
        /// <param name="categoriesRepository">The categories repository to retrieve, store and update categories.</param>
        /// <param name="imageSearchService">The service to use for finding an image for a category.</param>
        /// <param name="synonymService">The service to use for finding synonyms for a category.</param>
        /// <param name="eventGridPublisher">The service to use for publishing events.</param>
        public CategoriesService(
            ICategoriesRepository categoriesRepository,
            IImageSearchService imageSearchService,
            ISynonymService synonymService,
            IEventGridPublisherService eventGridPublisher)
        {
            this.categoriesRepository = categoriesRepository;
            this.imageSearchService = imageSearchService;
            this.synonymService = synonymService;
            this.eventGridPublisher = eventGridPublisher;
        }

        /// <summary>
        /// Validates the api service is up and running.
        /// </summary>
        /// <param name="userId">The id of the user performing the operation.</param>
        /// <param name="app">The app name hosting the service.</param>
        /// <returns>Results of the health check. See the <see cref="HealthCheckResults"/> class.</returns>
        public Task<HealthCheckResults> HealthCheckApi(string userId, string app)
        {
            var healthCheckResults = new HealthCheckResults()
            {
                    Status = HealthCheckStatus.OK,
                    Application = app,
            };
            return Task.FromResult<HealthCheckResults>(healthCheckResults);
        }

        /// <summary>
        /// Validates the worker service is up and running.
        /// </summary>
        /// <param name="userId">The id of the user performing the operation.</param>
        /// <param name="app">The app name hosting the service.</param>
        /// <returns>Results of the health check. See the <see cref="HealthCheckResults"/> class.</returns>
        public Task<HealthCheckResults> HealthCheckWorker(string userId, string app)
        {
            var healthCheckResults = new HealthCheckResults()
            {
                    Status = HealthCheckStatus.OK,
                    Application = app,
            };
            return Task.FromResult<HealthCheckResults>(healthCheckResults);
        }

        /// <summary>
        /// Adds a new category for the user.
        /// </summary>
        /// <param name="name">Name of the category to add.</param>
        /// <param name="userId">Id of the user performing the operation.</param>
        /// <returns>The id of the new category.</returns>
        public async Task<string> AddCategoryAsync(string name, string userId)
        {
            // create the document in Cosmos DB
            var categoryDocument = new CategoryDocument
            {
                Name = name,
                UserId = userId,
            };
            var categoryId = await this.categoriesRepository.AddCategoryAsync(categoryDocument).ConfigureAwait(false);

            // post a CategoryCreated event to Event Grid
            var eventData = new CategoryCreatedEventData
            {
                Name = name,
            };
            var subject = $"{userId}/{categoryId}";
            await this.eventGridPublisher.PostEventGridEventAsync(CategoryEvents.CategoryCreated, subject, eventData).ConfigureAwait(false);

            return categoryId;
        }

        /// <summary>
        /// Delete a category.
        /// </summary>
        /// <param name="categoryId">The id of the category to delete.</param>
        /// <param name="userId">The id of the user performing the operation.</param>
        /// <returns>The results of the delete operation. Instance of the <see cref="DeleteCategoryResult"/> class.</returns>
        public async Task<DeleteCategoryResult> DeleteCategoryAsync(string categoryId, string userId)
        {
            // delete the document from Cosmos DB
            var result = await this.categoriesRepository.DeleteCategoryAsync(categoryId, userId).ConfigureAwait(false);
            if (result == DeleteCategoryResult.NotFound)
            {
                return DeleteCategoryResult.NotFound;
            }

            // post a CategoryDeleted event to Event Grid
            var subject = $"{userId}/{categoryId}";
            await this.eventGridPublisher.PostEventGridEventAsync(CategoryEvents.CategoryDeleted, subject, new CategoryDeletedEventData()).ConfigureAwait(false);

            return DeleteCategoryResult.Success;
        }

        /// <summary>
        /// Updates the name of a category as well as the image and synonyms.
        /// </summary>
        /// <param name="categoryId">Id of the category to update.</param>
        /// <param name="userId">Id of the user performing the operation.</param>
        /// <param name="name">New name of the category.</param>
        /// <returns>The result of the update operation. An instance of the <see cref="UpdateCategoryResult"/> class.</returns>
        public async Task<UpdateCategoryResult> UpdateCategoryAsync(string categoryId, string userId, string name)
        {
            // get the current version of the document from Cosmos DB
            var categoryDocument = await this.categoriesRepository.GetCategoryAsync(categoryId, userId).ConfigureAwait(false);
            if (categoryDocument == null)
            {
                return UpdateCategoryResult.NotFound;
            }

            // update the document with the new name
            categoryDocument.Name = name;
            await this.categoriesRepository.UpdateCategoryAsync(categoryDocument).ConfigureAwait(false);

            // post a CategoryNameUpdated event to Event Grid
            var eventData = new CategoryNameUpdatedEventData
            {
                Name = name,
            };
            var subject = $"{userId}/{categoryId}";
            await this.eventGridPublisher.PostEventGridEventAsync(CategoryEvents.CategoryNameUpdated, subject, eventData).ConfigureAwait(false);

            return UpdateCategoryResult.Success;
        }

        /// <summary>
        /// Gets the details of a single category.
        /// </summary>
        /// <param name="categoryId">The id of the category to get.</param>
        /// <param name="userId">The id of the user performing the operation.</param>
        /// <returns>The details of the category.  An instance of the <see cref="CategoryDetails"/> class.</returns>
        public async Task<CategoryDetails> GetCategoryAsync(string categoryId, string userId)
        {
            var categoryDocument = await this.categoriesRepository.GetCategoryAsync(categoryId, userId).ConfigureAwait(false);
            if (categoryDocument == null)
            {
                return null;
            }

            var details = new CategoryDetails
            {
                Id = categoryDocument.Id,
                ImageUrl = categoryDocument.ImageUrl,
                Name = categoryDocument.Name,
            };

            ((List<string>)details.Synonyms).AddRange(categoryDocument.Synonyms);
            ((List<CategoryItemDetails>)details.Items).AddRange(categoryDocument.Items.Select(i => new CategoryItemDetails
            {
                Id = i.Id,
                Type = i.Type,
                Preview = i.Preview,
            }).ToList());

            return details;
        }

        /// <summary>
        /// Gets a list of categories for a single user.
        /// </summary>
        /// <param name="userId">The id of the user performing the get.</param>
        /// <returns>List of categories. Instance of the <see cref="CategorySummaryCollection"/> class.</returns>
        public Task<CategorySummaryCollection> ListCategoriesAsync(string userId)
        {
            return this.categoriesRepository.ListCategoriesAsync(userId);
        }

        /// <summary>
        /// Updates the synonyms for a category.
        /// </summary>
        /// <param name="categoryId">The id of the category to update.</param>
        /// <param name="userId">The id of the user peforming the operation.</param>
        /// <returns>Returns true of false based on whether synonyms were found.</returns>
        public async Task<bool> UpdateCategorySynonymsAsync(string categoryId, string userId)
        {
            // find the category document
            var categoryDocument = await this.categoriesRepository.GetCategoryAsync(categoryId, userId).ConfigureAwait(false);
            if (categoryDocument == null)
            {
                return false;
            }

            // retrieve the synonyms
            var synonyms = await this.synonymService.GetSynonymsAsync(categoryDocument.Name).ConfigureAwait(false);
            if (synonyms == null)
            {
                return false;
            }

            // get the document again, to reduce the likelihood of concurrency races
            categoryDocument = await this.categoriesRepository.GetCategoryAsync(categoryId, userId).ConfigureAwait(false);

            // update the document with the new name
            ((List<string>)categoryDocument.Synonyms).AddRange(synonyms);
            await this.categoriesRepository.UpdateCategoryAsync(categoryDocument).ConfigureAwait(false);

            // post a CategorySynonymsUpdatedEventData event to Event Grid
            var eventData = new CategorySynonymsUpdatedEventData
            {
                Synonyms = synonyms,
            };
            var subject = $"{userId}/{categoryId}";
            await this.eventGridPublisher.PostEventGridEventAsync(CategoryEvents.CategorySynonymsUpdated, subject, eventData).ConfigureAwait(false);

            return true;
        }

        /// <summary>
        /// Updates the image for a category.
        /// </summary>
        /// <param name="categoryId">The id of the category to update the image for.</param>
        /// <param name="userId">The id of the user that is performing the operation.</param>
        /// <returns>True or false based on whether the service was able to find an image for the category.</returns>
        public async Task<bool> UpdateCategoryImageAsync(string categoryId, string userId)
        {
            // find the category document
            var categoryDocument = await this.categoriesRepository.GetCategoryAsync(categoryId, userId).ConfigureAwait(false);
            if (categoryDocument == null)
            {
                return false;
            }

            // retrieve an image URL
            Uri imageUrl = await this.imageSearchService.FindImageUrlAsync(categoryDocument.Name).ConfigureAwait(false);
            if (imageUrl == null)
            {
                return false;
            }

            // get the document again, to reduce the likelihood of concurrency races
            categoryDocument = await this.categoriesRepository.GetCategoryAsync(categoryId, userId).ConfigureAwait(false);

            // update the document with the new name
            categoryDocument.ImageUrl = imageUrl;
            await this.categoriesRepository.UpdateCategoryAsync(categoryDocument).ConfigureAwait(false);

            // post a CategoryImageUpdatedEventData event to Event Grid
            var eventData = new CategoryImageUpdatedEventData
            {
                ImageUrl = imageUrl,
            };
            var subject = $"{userId}/{categoryId}";
            await this.eventGridPublisher.PostEventGridEventAsync(CategoryEvents.CategoryImageUpdated, subject, eventData).ConfigureAwait(false);

            return true;
        }

        /// <summary>
        /// Processes the add item event and adds the summary of the item to the parent category.
        /// </summary>
        /// <param name="eventToProcess">The event to process.</param>
        /// <param name="userId">The user id the event is for.</param>
        /// <returns>Task to perform the operation.</returns>
        public async Task ProcessAddItemEventAsync(EventGridEvent eventToProcess, string userId)
        {
            if (eventToProcess == null)
            {
                throw new ArgumentNullException(nameof(eventToProcess));
            }

            // process the item type
            var (item, categoryId, operationType) = this.ConvertEventGridEventToCategoryItem(eventToProcess);
            if (operationType != OperationType.Add)
            {
                return;
            }

            // find the category document
            var categoryDocument = await this.categoriesRepository.GetCategoryAsync(categoryId, userId).ConfigureAwait(false);
            if (categoryDocument == null)
            {
                return;
            }

            // update the document with the new item
            // and if the item already exists in this category, replace it
            var existingItem = categoryDocument.Items.SingleOrDefault(i => i.Id == item.Id);
            if (existingItem != null)
            {
                categoryDocument.Items.Remove(existingItem);
            }

            categoryDocument.Items.Add(item);
            await this.categoriesRepository.UpdateCategoryAsync(categoryDocument).ConfigureAwait(false);

            // post a CategoryItemsUpdated event to Event Grid
            var eventData = new CategoryItemsUpdatedEventData();
            var subject = $"{userId}/{categoryDocument.Id}";
            await this.eventGridPublisher.PostEventGridEventAsync(CategoryEvents.CategoryItemsUpdated, subject, eventData).ConfigureAwait(false);
        }

        /// <summary>
        /// Updates teh copy of the item data in the category document when the update item event is raised.
        /// </summary>
        /// <param name="eventToProcess">The event to process.</param>
        /// <param name="userId">The id of the user the item is for.</param>
        /// <returns>The task to perform the operation.</returns>
        public async Task ProcessUpdateItemEventAsync(EventGridEvent eventToProcess, string userId)
        {
            if (eventToProcess == null)
            {
                throw new ArgumentNullException(nameof(eventToProcess));
            }

            // process the item type
            var (updatedItem, _, operationType) = this.ConvertEventGridEventToCategoryItem(eventToProcess);
            if (operationType != OperationType.Update)
            {
                return;
            }

            // find the category document
            var categoryDocument = await this.categoriesRepository.FindCategoryWithItemAsync(updatedItem.Id, updatedItem.Type, userId).ConfigureAwait(false);
            if (categoryDocument == null)
            {
                return;
            }

            // find the item in the document
            var existingItem = categoryDocument.Items.SingleOrDefault(i => i.Id == updatedItem.Id);
            if (existingItem == null)
            {
                return;
            }

            // update the item with the latest changes
            // (the only field that can change is Preview)
            existingItem.Preview = updatedItem.Preview;
            await this.categoriesRepository.UpdateCategoryAsync(categoryDocument).ConfigureAwait(false);

            // post a CategoryItemsUpdated event to Event Grid
            var eventData = new CategoryItemsUpdatedEventData();
            var subject = $"{userId}/{categoryDocument.Id}";
            await this.eventGridPublisher.PostEventGridEventAsync(CategoryEvents.CategoryItemsUpdated, subject, eventData).ConfigureAwait(false);
        }

        /// <summary>
        /// Removes a deleted item from the category document when the item deleted event is raised.
        /// </summary>
        /// <param name="eventToProcess">The event to process.</param>
        /// <param name="userId">The user that owns the item.</param>
        /// <returns>The task to perform the operation.</returns>
        public async Task ProcessDeleteItemEventAsync(EventGridEvent eventToProcess, string userId)
        {
            if (eventToProcess == null)
            {
                throw new ArgumentNullException(nameof(eventToProcess));
            }

            // process the item type
            var (updatedItem, _, operationType) = this.ConvertEventGridEventToCategoryItem(eventToProcess);
            if (operationType != OperationType.Delete)
            {
                return;
            }

            // find the category document
            var categoryDocument = await this.categoriesRepository.FindCategoryWithItemAsync(updatedItem.Id, updatedItem.Type, userId).ConfigureAwait(false);
            if (categoryDocument == null)
            {
                return;
            }

            // find the item in the document
            var itemToRemove = categoryDocument.Items.SingleOrDefault(i => i.Id == updatedItem.Id);
            if (itemToRemove == null)
            {
                return;
            }

            // remove the item from the document
            categoryDocument.Items.Remove(itemToRemove);
            await this.categoriesRepository.UpdateCategoryAsync(categoryDocument).ConfigureAwait(false);

            // post a CategoryItemsUpdated event to Event Grid
            var eventData = new CategoryItemsUpdatedEventData();
            var subject = $"{userId}/{categoryDocument.Id}";
            await this.eventGridPublisher.PostEventGridEventAsync(CategoryEvents.CategoryItemsUpdated, subject, eventData).ConfigureAwait(false);
        }

        private (CategoryItem categoryItem, string categoryId, OperationType operationType) ConvertEventGridEventToCategoryItem(EventGridEvent eventToProcess)
        {
            var item = new CategoryItem
            {
                Id = eventToProcess.Subject.Split('/')[1], // we assume the subject has previously been checked for its format
            };

            string categoryId;
            OperationType operationType;
            switch (eventToProcess.EventType)
            {
                case AudioEvents.AudioCreated:
                    var audioCreatedEventData = (AudioCreatedEventData)eventToProcess.Data;
                    item.Type = ItemType.Audio;
                    item.Preview = audioCreatedEventData.TranscriptPreview;
                    categoryId = audioCreatedEventData.Category;
                    operationType = OperationType.Add;
                    break;

                case ImageEvents.ImageCreated:
                    var imageCreatedEventData = (ImageCreatedEventData)eventToProcess.Data;
                    item.Type = ItemType.Image;
                    item.Preview = imageCreatedEventData.PreviewUri.ToString();
                    categoryId = imageCreatedEventData.Category;
                    operationType = OperationType.Add;
                    break;

                case TextEvents.TextCreated:
                    var textCreatedEventData = (TextCreatedEventData)eventToProcess.Data;
                    item.Type = ItemType.Text;
                    item.Preview = textCreatedEventData.Preview;
                    categoryId = textCreatedEventData.Category;
                    operationType = OperationType.Add;
                    break;

                case AudioEvents.AudioTranscriptUpdated:
                    var audioTranscriptUpdatedEventData = (AudioTranscriptUpdatedEventData)eventToProcess.Data;
                    item.Type = ItemType.Audio;
                    item.Preview = audioTranscriptUpdatedEventData.TranscriptPreview;
                    categoryId = null;
                    operationType = OperationType.Update;
                    break;

                case TextEvents.TextUpdated:
                    var textUpdatedEventData = (TextUpdatedEventData)eventToProcess.Data;
                    item.Type = ItemType.Text;
                    item.Preview = textUpdatedEventData.Preview;
                    categoryId = null;
                    operationType = OperationType.Update;
                    break;

                case AudioEvents.AudioDeleted:
                    item.Type = ItemType.Audio;
                    categoryId = null;
                    operationType = OperationType.Delete;
                    break;

                case ImageEvents.ImageDeleted:
                    item.Type = ItemType.Image;
                    categoryId = null;
                    operationType = OperationType.Delete;
                    break;

                case TextEvents.TextDeleted:
                    item.Type = ItemType.Text;
                    categoryId = null;
                    operationType = OperationType.Delete;
                    break;

                default:
                    throw new ArgumentException($"Unexpected event type '{eventToProcess.EventType}' in {nameof(this.ProcessAddItemEventAsync)}");
            }

            if (operationType == OperationType.Add && string.IsNullOrEmpty(categoryId))
            {
                throw new InvalidOperationException("Category ID must be set for new items.");
            }

            return (item, categoryId, operationType);
        }
    }
}
