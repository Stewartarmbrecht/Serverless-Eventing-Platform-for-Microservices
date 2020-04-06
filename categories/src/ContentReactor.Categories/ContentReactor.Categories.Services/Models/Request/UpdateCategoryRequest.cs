namespace ContentReactor.Categories.Services.Models.Request
{
    using Newtonsoft.Json;

    /// <summary>
    /// Structures the request for updating a category.
    /// </summary>
    public class UpdateCategoryRequest
    {
        /// <summary>
        /// Gets or sets the id of the category to update.
        /// </summary>
        [JsonProperty("id")]
        public string Id { get; set; }

        /// <summary>
        /// Gets or sets the new name for the category.
        /// </summary>
        [JsonProperty("name")]
        public string Name { get; set; }
    }
}