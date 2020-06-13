namespace ContentReactor.Audio.Service
{
    using System;
    using Newtonsoft.Json;

    /// <summary>
    /// Provides meta data and access url to download an audio file.
    /// </summary>
    public class GetResponse
    {
        /// <summary>
        /// Gets or sets id of the audio file.
        /// </summary>
        [JsonProperty("id")]
        public string Id { get; set; }

        /// <summary>
        /// Gets or sets url to download audio file.
        /// </summary>
        [JsonProperty("audioUrl")]
        public Uri AudioUrl { get; set; }

        /// <summary>
        /// Gets or sets transcript of the audio file.
        /// </summary>
        [JsonProperty("transcript")]
        public string Transcript { get; set; }
    }
}
