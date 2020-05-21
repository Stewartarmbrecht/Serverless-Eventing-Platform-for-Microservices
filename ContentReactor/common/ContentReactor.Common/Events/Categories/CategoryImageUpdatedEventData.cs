namespace ContentReactor.Common.Events.Categories
{
    /// <summary>
    /// Event raised when a category image is updated.
    /// </summary>
    public class CategoryImageUpdatedEventData
    {
        /// <summary>
        /// Gets or sets the URL to the updated image.
        /// </summary>
        /// <value>String.</value>
        public System.Uri ImageUrl { get; set; }
    }
}