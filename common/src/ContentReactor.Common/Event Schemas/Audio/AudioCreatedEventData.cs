namespace ContentReactor.Common.EventSchemas.Audio
{
    /// <summary>
    /// Audio created event data.
    /// </summary>
    public class AudioCreatedEventData
    {
        /// <summary>
        /// Gets or sets the preview of the audio transcription.
        /// </summary>
        /// <value>String preview.</value>
        public string TranscriptPreview { get; set; }

        /// <summary>
        /// Gets or sets the category the audio was uploaded to.
        /// </summary>
        /// <value>String name of the cateogry.</value>
        public string Category { get; set; }
    }
}