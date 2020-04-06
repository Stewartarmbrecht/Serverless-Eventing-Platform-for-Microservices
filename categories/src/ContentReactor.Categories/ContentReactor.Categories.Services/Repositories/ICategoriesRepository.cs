namespace ContentReactor.Categories.Services.Repositories
{
    using System.Threading.Tasks;
    using ContentReactor.Categories.Services.Models;
    using ContentReactor.Categories.Services.Models.Data;
    using ContentReactor.Categories.Services.Models.Response;
    using ContentReactor.Categories.Services.Models.Results;

    /// <summary>
    /// Interface for managing a repository of categories.
    /// </summary>
    public interface ICategoriesRepository
    {
        /// <summary>
        /// Adds a new cagtegory.
        /// </summary>
        /// <param name="categoryDocument">The document representation of the category.</param>
        /// <returns>The id of the category.</returns>
        Task<string> AddCategoryAsync(CategoryDocument categoryDocument);

        /// <summary>
        /// Deletes a category.
        /// </summary>
        /// <param name="categoryId">The Id of the category to delete.</param>
        /// <param name="userId">The id of the user that owns the category.</param>
        /// <returns>The results of the delete operation.</returns>
        Task<DeleteCategoryResult> DeleteCategoryAsync(string categoryId, string userId);

        /// <summary>
        /// Updates a category.
        /// </summary>
        /// <param name="categoryDocument">The category details to update.</param>
        /// <returns>The results of the category update.</returns>
        Task<UpdateCategoryResult> UpdateCategoryAsync(CategoryDocument categoryDocument);

        /// <summary>
        /// Gets the details of a single category.
        /// </summary>
        /// <param name="categoryId">The id of the category to retrieve.</param>
        /// <param name="userId">The user id that owns the category.</param>
        /// <returns>The category document. An instance of the <see cref="CategoryDocument"/> class.</returns>
        Task<CategoryDocument> GetCategoryAsync(string categoryId, string userId);

        /// <summary>
        /// Gets a list of categories.
        /// </summary>
        /// <param name="userId">The user id to get the categories for.</param>
        /// <returns>Collection of category summaries.</returns>
        Task<CategorySummaryCollection> ListCategoriesAsync(string userId);

        /// <summary>
        /// Gets a category that has a specific item.
        /// </summary>
        /// <param name="itemId">The item id to get the category for.</param>
        /// <param name="itemType">The type of the item.</param>
        /// <param name="userId">The user id that owns the item and parent category.</param>
        /// <returns>The details of the category. An instance of the <see cref="CategoryDocument"/> class.</returns>
        Task<CategoryDocument> FindCategoryWithItemAsync(string itemId, ItemType itemType, string userId);
    }
}