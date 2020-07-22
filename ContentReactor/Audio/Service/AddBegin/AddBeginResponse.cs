namespace ContentReactor.Audio.Service
{
    using System;
    using Newtonsoft.Json;

    /// <summary>
    /// Includes the Id and url to upload the new audio file to.
    /// </summary>
    public class AddBeginResponse
    {
        /// <summary>
        /// Gets or sets the id of the new audio blob.
        /// </summary>
        /// <value>String value for a guid.</value>
        [JsonProperty("id")]
        public string Id { get; set; }

        /// <summary>
        /// Gets or sets the url that has the shared access key to upload a file to the newly created blob.
        /// </summary>
        /// <value>The string value of the URL to upload the audio file.</value>
        [JsonProperty("url")]
        public Uri UploadUrl { get; set; }
    }
}
