namespace ContentReactor.Categories.Services.Models.Response
{
    using Newtonsoft.Json;

    /// <summary>
    /// Provides just the name and id for a category.
    /// </summary>
    public class CategorySummary
    {
        /// <summary>
        /// Gets or sets the id for the category.
        /// </summary>
        /// <value>The Id of the category.</value>
        public string Id { get; set; }

        /// <summary>
        /// Gets or sets the name of the category summary.
        /// </summary>
        /// <value>The Id of the category.</value>
        [JsonProperty("name")]
        public string Name { get; set; }
    }
}
