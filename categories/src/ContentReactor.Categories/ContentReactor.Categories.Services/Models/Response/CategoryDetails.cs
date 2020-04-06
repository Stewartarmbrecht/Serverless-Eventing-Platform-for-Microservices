namespace ContentReactor.Categories.Services.Models.Response
{
    using System;
    using System.Collections.Generic;
    using Newtonsoft.Json;

    /// <summary>
    /// Represents the details of a single category.
    /// </summary>
    public class CategoryDetails
    {
        /// <summary>
        /// Gets or sets the id of a category.
        /// </summary>
        /// <value>The id of the category.</value>
        [JsonProperty("id")]
        public string Id { get; set; }

        /// <summary>
        /// Gets or sets the name of the category.
        /// </summary>
        /// <value>The name of the category.</value>
        [JsonProperty("name")]
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the url to the image for the category.
        /// </summary>
        /// <value>The Url of the image.</value>
        [JsonProperty("imageUrl")]
        public Uri ImageUrl { get; set; }

        /// <summary>
        /// Gets the list of synonyms.
        /// </summary>
        /// <value>A list of the synonyms for the category name.</value>
        [JsonProperty("synonyms")]
        public IList<string> Synonyms { get; } = new List<string>();

        /// <summary>
        /// Gets the Items for the category.
        /// </summary>
        /// <value>A list of the items for the category.</value>
        [JsonProperty("items")]
        public IList<CategoryItemDetails> Items { get; } = new List<CategoryItemDetails>();
    }
}
