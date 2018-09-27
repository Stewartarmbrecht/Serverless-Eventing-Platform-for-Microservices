namespace ContentReactor.Shared.EventSchemas.Audio
{
    /// <summary>
    /// Audio created event data.
    /// </summary>
    public class AudioCreatedEventData
    {
        public string TranscriptPreview { get; set; }
        public string Category { get; set; }
    }
}