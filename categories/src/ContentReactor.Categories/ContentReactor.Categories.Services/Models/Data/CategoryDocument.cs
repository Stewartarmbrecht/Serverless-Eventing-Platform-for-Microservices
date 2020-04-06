namespace ContentReactor.Categories.Services.Models.Data
{
    using System;
    using System.Collections.Generic;
    using Newtonsoft.Json;

    /// <summary>
    /// Represents a category document.
    /// </summary>
    public class CategoryDocument
    {
        /// <summary>
        /// Gets or sets the id of the category.
        /// </summary>
        /// <value>Id of the category.</value>
        [JsonProperty("id")]
        public string Id { get; set; }

        /// <summary>
        /// Gets or sets the id of the user that owns the category.
        /// </summary>
        /// <value>Id of the user who owns the category.</value>
        [JsonProperty("userId")]
        public string UserId { get; set; }

        /// <summary>
        /// Gets or sets the ETag of the category to help with caching the category data.
        /// </summary>
        /// <value>The eTag for the document.</value>
        [JsonProperty("_etag")]
        public string ETag { get; set; }

        /// <summary>
        /// Gets or sets the name of the category.
        /// </summary>
        /// <value>The name of the category.</value>
        [JsonProperty("name")]
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the url to a representative image of the category.
        /// </summary>
        /// <value>The Url to a representative image of the category.</value>
        [JsonProperty("imageUrl")]
        public Uri ImageUrl { get; set; }

        /// <summary>
        /// Gets the synonyms for the category if any were found.
        /// </summary>
        /// <returns>List of synonyms.</returns>
        [JsonProperty("synonyms")]
        public IList<string> Synonyms { get; } = new List<string>();

        /// <summary>
        /// Gets the list of items uploaded for each category.
        /// </summary>
        /// <returns>A list of category items.  See <see cref="CategoryItem"/> class.</returns>
        [JsonProperty("items")]
        public IList<CategoryItem> Items { get; } = new List<CategoryItem>();
    }
}
