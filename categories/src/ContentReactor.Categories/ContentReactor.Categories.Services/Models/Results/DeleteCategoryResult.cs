namespace ContentReactor.Categories.Services.Models.Results
{
    /// <summary>
    /// Potential results for deleting a category.
    /// </summary>
    public enum DeleteCategoryResult
    {
        /// <summary>
        /// The delete was successful.
        /// </summary>
        Success,

        /// <summary>
        /// The category was not found to delete.
        /// </summary>
        NotFound,
    }
}
