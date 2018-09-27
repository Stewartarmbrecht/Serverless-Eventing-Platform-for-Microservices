namespace ContentReactor.Audio.Services.Models.Responses
{
    using Newtonsoft.Json;

    /// <summary>
    /// Audio note metadata.
    /// </summary>
    public class AudioNoteSummary
    {
        /// <summary>
        /// Gets or sets id of the audio note.
        /// </summary>
        [JsonProperty("id")]
        public string Id { get; set; }

        /// <summary>
        /// Gets or sets preview of the audio not transcription.
        /// </summary>
        [JsonProperty("preview")]
        public string Preview { get; set; }
    }
}
