namespace ContentReactor.Categories.Services.Models.Request
{
    using Newtonsoft.Json;

    /// <summary>
    /// The shape of the request for creating a category.
    /// </summary>
    public class CreateCategoryRequest
    {
        /// <summary>
        /// Gets or sets the name of the new category.
        /// </summary>
        [JsonProperty("name")]
        public string Name { get; set; }
    }
}