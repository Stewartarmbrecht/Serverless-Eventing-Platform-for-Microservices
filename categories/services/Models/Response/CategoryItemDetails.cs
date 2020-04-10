namespace ContentReactor.Categories.Services.Models.Response
{
    using Newtonsoft.Json;
    using Newtonsoft.Json.Converters;

    /// <summary>
    /// Represents the details of a single category item.
    /// </summary>
    public class CategoryItemDetails
    {
        /// <summary>
        /// Gets or sets the id of the category item.
        /// </summary>
        /// <value>The id of the category item.</value>
        [JsonProperty("id")]
        public string Id { get; set; }

        /// <summary>
        /// Gets or sets the type of category item.
        /// </summary>
        /// <value>The type of the category item.</value>
        [JsonProperty("type")]
        [JsonConverter(typeof(StringEnumConverter))]
        public ItemType Type { get; set; }

        /// <summary>
        /// Gets or sets the preview for the category item.
        /// </summary>
        /// <value>The string preview of the category item.</value>
        [JsonProperty("preview")]
        public string Preview { get; set; }
    }
}