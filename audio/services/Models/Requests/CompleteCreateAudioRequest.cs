namespace ContentReactor.Audio.Services.Models.Requests
{
    using Newtonsoft.Json;

    /// <summary>
    /// Defines the shape of the request to complete an audio file (after it has been uploaded to the blog storage).
    /// </summary>
    public class CompleteCreateAudioRequest
    {
        /// <summary>
        /// Gets or sets the id of the category that the audio file should be organized under.
        /// </summary>
        /// <value>The id of the category the audio note was added to.</value>
        [JsonProperty("categoryId")]
        public string CategoryId { get; set; }
    }
}
