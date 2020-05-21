namespace ContentReactor.Categories.Services.Models.Results
{
    /// <summary>
    /// The potential results for updating a category.
    /// </summary>
    public enum UpdateCategoryResult
    {
        /// <summary>
        /// The update is successful.
        /// </summary>
        Success,

        /// <summary>
        /// The category was not found to update.
        /// </summary>
        NotFound,
    }
}
