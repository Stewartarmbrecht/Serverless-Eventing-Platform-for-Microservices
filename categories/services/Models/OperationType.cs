namespace ContentReactor.Categories.Services.Models
{
    /// <summary>
    /// The type of operation being performed with a category item for a category.
    /// </summary>
    public enum OperationType
    {
        /// <summary>
        /// The category item is being or was added.
        /// </summary>
        Add,

        /// <summary>
        /// The category item is being or was updated.
        /// </summary>
        Update,

        /// <summary>
        /// The category item is being or was deleted.
        /// </summary>
        Delete,
    }
}