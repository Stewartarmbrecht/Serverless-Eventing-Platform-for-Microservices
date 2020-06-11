namespace ContentReactor.Events.Images
{
    /// <summary>
    /// Event raised when an image is created.
    /// </summary>
    public class ImageCreatedEventData
    {
        /// <summary>
        /// Gets or sets the Url to the preview of the image.
        /// </summary>
        /// <value>System.Uri.</value>
        public System.Uri PreviewUri { get; set; }

        /// <summary>
        /// Gets or sets the category for the newly created image.
        /// </summary>
        /// <value>String.</value>
        public string Category { get; set; }
    }
}