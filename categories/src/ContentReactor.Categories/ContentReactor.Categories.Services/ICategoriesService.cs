namespace ContentReactor.Categories.Services
{
    using System.Threading.Tasks;
    using ContentReactor.Categories.Services.Models.Response;
    using ContentReactor.Categories.Services.Models.Results;
    using ContentReactor.Common;

    /// <summary>
    /// Interface for the categories service.
    /// </summary>
    public interface ICategoriesService
    {
        /// <summary>
        /// Validates the api service is up and running.
        /// </summary>
        /// <param name="userId">The id of the user performing the operation.</param>
        /// <param name="app">The app name hosting the service.</param>
        /// <returns>Results of the health check. See the <see cref="HealthCheckResults"/> class.</returns>
        Task<HealthCheckResults> HealthCheckApi(string userId, string app);

        /// <summary>
        /// Validates the worker service is up and running.
        /// </summary>
        /// <param name="userId">The id of the user performing the operation.</param>
        /// <param name="app">The app name hosting the service.</param>
        /// <returns>Results of the health check. See the <see cref="HealthCheckResults"/> class.</returns>
        Task<HealthCheckResults> HealthCheckWorker(string userId, string app);

        /// <summary>
        /// Adds a new category for the user.
        /// </summary>
        /// <param name="name">Name of the category to add.</param>
        /// <param name="userId">Id of the user performing the operation.</param>
        /// <returns>The id of the new category.</returns>
        Task<string> AddCategoryAsync(string name, string userId);

        /// <summary>
        /// Delete a category.
        /// </summary>
        /// <param name="categoryId">The id of the category to delete.</param>
        /// <param name="userId">The id of the user performing the operation.</param>
        /// <returns>The results of the delete operation. Instance of the <see cref="DeleteCategoryResult"/> class.</returns>
        Task<DeleteCategoryResult> DeleteCategoryAsync(string categoryId, string userId);

        /// <summary>
        /// Updates the name of a category as well as the image and synonyms.
        /// </summary>
        /// <param name="categoryId">Id of the category to update.</param>
        /// <param name="userId">Id of the user performing the operation.</param>
        /// <param name="name">New name of the category.</param>
        /// <returns>The result of the update operation. An instance of the <see cref="UpdateCategoryResult"/> class.</returns>
        Task<UpdateCategoryResult> UpdateCategoryAsync(string categoryId, string userId, string name);

        /// <summary>
        /// Gets the details of a single category.
        /// </summary>
        /// <param name="categoryId">The id of the category to get.</param>
        /// <param name="userId">The id of the user performing the operation.</param>
        /// <returns>The details of the category.  An instance of the <see cref="CategoryDetails"/> class.</returns>
        Task<CategoryDetails> GetCategoryAsync(string categoryId, string userId);

        /// <summary>
        /// Gets a list of categories for a single user.
        /// </summary>
        /// <param name="userId">The id of the user performing the get.</param>
        /// <returns>List of categories. Instance of the <see cref="CategorySummaryCollection"/> class.</returns>
        Task<CategorySummaryCollection> ListCategoriesAsync(string userId);

        /// <summary>
        /// Updates the synonyms for a category.
        /// </summary>
        /// <param name="categoryId">The id of the category to update.</param>
        /// <param name="userId">The id of the user peforming the operation.</param>
        /// <returns>Returns true of false based on whether synonyms were found.</returns>
        Task<bool> UpdateCategoryImageAsync(string categoryId, string userId);

        /// <summary>
        /// Updates the image for a category.
        /// </summary>
        /// <param name="categoryId">The id of the category to update the image for.</param>
        /// <param name="userId">The id of the user that is performing the operation.</param>
        /// <returns>True or false based on whether the service was able to find an image for the category.</returns>
        Task<bool> UpdateCategorySynonymsAsync(string categoryId, string userId);

        /// <summary>
        /// Processes the add item event and adds the summary of the item to the parent category.
        /// </summary>
        /// <param name="eventToProcess">The event to process.</param>
        /// <param name="userId">The user id the event is for.</param>
        /// <returns>Task to perform the operation.</returns>
        Task ProcessAddItemEventAsync(EventGridEvent eventToProcess, string userId);

        /// <summary>
        /// Updates teh copy of the item data in the category document when the update item event is raised.
        /// </summary>
        /// <param name="eventToProcess">The event to process.</param>
        /// <param name="userId">The id of the user the item is for.</param>
        /// <returns>The task to perform the operation.</returns>
        Task ProcessUpdateItemEventAsync(EventGridEvent eventToProcess, string userId);

        /// <summary>
        /// Removes a deleted item from the category document when the item deleted event is raised.
        /// </summary>
        /// <param name="eventToProcess">The event to process.</param>
        /// <param name="userId">The user that owns the item.</param>
        /// <returns>The task to perform the operation.</returns>
        Task ProcessDeleteItemEventAsync(EventGridEvent eventToProcess, string userId);
    }
}
