namespace ContentReactor.Events.Categories
{
    /// <summary>
    /// Event raised when a category is created.
    /// </summary>
    public class CategoryCreatedEventData
    {
        /// <summary>
        /// Gets or sets the name of the new category.
        /// </summary>
        /// <value>String.</value>
        public string Name { get; set; }
    }
}
