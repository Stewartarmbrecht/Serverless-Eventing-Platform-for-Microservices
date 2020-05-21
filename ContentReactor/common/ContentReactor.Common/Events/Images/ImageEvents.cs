namespace ContentReactor.Common.Events.Images
{
    /// <summary>
    /// Events for images.
    /// </summary>
    public static class ImageEvents
    {
        /// <summary>
        /// Type for an event when an image caption is updated.
        /// </summary>
        /// <returns>String.</returns>
        public const string ImageCaptionUpdated = nameof(ImageCaptionUpdated);

        /// <summary>
        /// Type for an event when an image is uploaded.
        /// </summary>
        /// <returns>String.</returns>
        public const string ImageCreated = nameof(ImageCreated);

        /// <summary>
        /// Type for an event when an image is deleted.
        /// </summary>
        /// <returns>String.</returns>
        public const string ImageDeleted = nameof(ImageDeleted);
    }
}