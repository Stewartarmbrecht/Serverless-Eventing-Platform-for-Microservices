namespace ContentReactor.Events.Categories
{
    using System.Collections.Generic;

    /// <summary>
    /// Event raised when the synonyms for a category are updated.
    /// </summary>
    public class CategorySynonymsUpdatedEventData
    {
        /// <summary>
        /// Gets or sets the name of the category.
        /// </summary>
        /// <value>String.</value>
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the list of synonyms for the category.
        /// </summary>
        /// <value>IEnumberable of Strings.</value>
        public IEnumerable<string> Synonyms { get; set; }
    }
}