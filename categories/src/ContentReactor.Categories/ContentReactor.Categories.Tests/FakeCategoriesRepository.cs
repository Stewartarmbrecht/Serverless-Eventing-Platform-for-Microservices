namespace ContentReactor.Categories.Tests
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

    /// <summary>
    /// Provides a fake implementation of the categories repository to support testing.
    /// </summary>
    public class FakeCategoriesRepository : ICategoriesRepository
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="FakeCategoriesRepository"/> class.
        /// </summary>
        public FakeCategoriesRepository()
        {
            this.CategoryDocuments = new List<CategoryDocument>();
        }

        /// <summary>
        /// Gets the internal collection of Category Documents.
        /// </summary>
        /// <value>List of <see cref="CategoryDocument"/> instances.</value>
        public IList<CategoryDocument> CategoryDocuments { get; }

        /// <summary>
        /// Adds a new cagtegory.
        /// </summary>
        /// <param name="categoryDocument">The document representation of the category.</param>
        /// <returns>The id of the category.</returns>
        public Task<string> AddCategoryAsync(CategoryDocument categoryDocument)
        {
            if (string.IsNullOrEmpty(categoryDocument.Id))
            {
                categoryDocument.Id = Guid.NewGuid().ToString();
            }

            this.CategoryDocuments.Add(categoryDocument);
            return Task.FromResult(categoryDocument.Id);
        }

        /// <summary>
        /// Deletes a category.
        /// </summary>
        /// <param name="categoryId">The Id of the category to delete.</param>
        /// <param name="userId">The id of the user that owns the category.</param>
        /// <returns>The results of the delete operation.</returns>
        public Task<DeleteCategoryResult> DeleteCategoryAsync(string categoryId, string userId)
        {
            var documentToRemove = this.CategoryDocuments.SingleOrDefault(d => d.Id == categoryId && d.UserId == userId);
            if (documentToRemove == null)
            {
                return Task.FromResult(DeleteCategoryResult.NotFound);
            }

            this.CategoryDocuments.Remove(documentToRemove);
            return Task.FromResult(DeleteCategoryResult.Success);
        }

        /// <summary>
        /// Updates a category.
        /// </summary>
        /// <param name="categoryDocument">The category details to update.</param>
        /// <returns>The results of the category update.</returns>
        public async Task<UpdateCategoryResult> UpdateCategoryAsync(CategoryDocument categoryDocument)
        {
            var documentToUpdate = await Task.Run(
                () => this.CategoryDocuments.SingleOrDefault(d => d.Id == categoryDocument.Id && d.UserId == categoryDocument.UserId))
                .ConfigureAwait(false);
            if (documentToUpdate == null)
            {
                return UpdateCategoryResult.NotFound;
            }

            documentToUpdate.Name = categoryDocument.Name;
            return UpdateCategoryResult.Success;
        }

        /// <summary>
        /// Gets the details of a single category.
        /// </summary>
        /// <param name="categoryId">The id of the category to retrieve.</param>
        /// <param name="userId">The user id that owns the category.</param>
        /// <returns>The category document. An instance of the <see cref="CategoryDocument"/> class.</returns>
        public Task<CategoryDocument> GetCategoryAsync(string categoryId, string userId)
        {
            var document = this.CategoryDocuments.SingleOrDefault(d => d.Id == categoryId && d.UserId == userId);
            return Task.FromResult(document);
        }

        /// <summary>
        /// Gets a list of categories.
        /// </summary>
        /// <param name="userId">The user id to get the categories for.</param>
        /// <returns>Collection of category summaries.</returns>
        public Task<CategorySummaryCollection> ListCategoriesAsync(string userId)
        {
            var list = this.CategoryDocuments
                .Where(d => d.UserId == userId)
                .Select(d => new CategorySummary { Id = d.Id, Name = d.Name })
                .ToList();
            var categorySummaries = new CategorySummaryCollection();
            categorySummaries.AddRange(list);
            return Task.FromResult(categorySummaries);
        }

        /// <summary>
        /// Gets a category that has a specific item.
        /// </summary>
        /// <param name="itemId">The item id to get the category for.</param>
        /// <param name="itemType">The type of the item.</param>
        /// <param name="userId">The user id that owns the item and parent category.</param>
        /// <returns>The details of the category. An instance of the <see cref="CategoryDocument"/> class.</returns>
        public Task<CategoryDocument> FindCategoryWithItemAsync(string itemId, ItemType itemType, string userId)
        {
            var list = this.CategoryDocuments
                .Where(d => d.UserId == userId && d.Items.Any(i => i.Id == itemId && i.Type == itemType))
                .ToList();
            return Task.FromResult(list.SingleOrDefault());
        }
    }
}
