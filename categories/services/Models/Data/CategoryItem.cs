namespace ContentReactor.Categories.Services.Models.Data
{
    using Newtonsoft.Json;
    using Newtonsoft.Json.Converters;

    /// <summary>
    /// Represents an item stored under a category.
    /// </summary>
    public class CategoryItem
    {
        /// <summary>
        /// Gets or sets the id of the category.
        /// </summary>
        /// <value>The id of the category.</value>
        [JsonProperty("id")]
        public string Id { get; set; }

        /// <summary>
        /// Gets or sets the type of category item.
        /// </summary>
        /// <value>The type of category. An instance of the <see cref="ItemType"/> enum.</value>
        [JsonProperty("type")]
        [JsonConverter(typeof(StringEnumConverter))]
        public ItemType Type { get; set; }

        /// <summary>
        /// Gets or sets the string preview of the item.
        /// </summary>
        /// <value>A string preview of the item.</value>
        [JsonProperty("preview")]
        public string Preview { get; set; }
    }
}