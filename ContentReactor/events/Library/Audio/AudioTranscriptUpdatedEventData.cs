namespace ContentReactor.Events.Audio
{
    /// <summary>
    /// Event raised when an audio file has been transcribed.
    /// </summary>
    public class AudioTranscriptUpdatedEventData
    {
        /// <summary>
        /// Gets or sets the preview of the transcription created for an audio file.
        /// </summary>
        /// <value>String value of the transcription preview.</value>
        public string TranscriptPreview { get; set; }
    }
}