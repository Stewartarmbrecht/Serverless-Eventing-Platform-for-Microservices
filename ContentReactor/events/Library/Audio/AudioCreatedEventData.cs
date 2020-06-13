namespace ContentReactor.Events.Audio
{
    /// <summary>
    /// Audio created event data.
    /// </summary>
    public class AudioCreatedEventData
    {
        /// <summary>
        /// Gets or sets the category the audio was uploaded to.
        /// </summary>
        /// <value>String name of the cateogry.</value>
        public string Category { get; set; }
    }
}