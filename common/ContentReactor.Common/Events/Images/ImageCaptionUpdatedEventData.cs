namespace ContentReactor.Common.Events.Images
{
    /// <summary>
    /// Event raised when an image caption is updated.
    /// </summary>
    public class ImageCaptionUpdatedEventData
    {
        /// <summary>
        /// Gets or sets the caption that was updated for the image.
        /// </summary>
        /// <value>String.</value>
        public string Caption { get; set; }
    }
}