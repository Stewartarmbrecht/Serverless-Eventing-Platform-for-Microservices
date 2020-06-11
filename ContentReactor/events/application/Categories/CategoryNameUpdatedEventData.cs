namespace ContentReactor.Events.Categories
{
    /// <summary>
    /// Event raised when a category name is updated.
    /// </summary>
    public class CategoryNameUpdatedEventData
    {
        /// <summary>
        /// Gets or sets the name of the new cateogry.
        /// </summary>
        /// <value>String.</value>
        public string Name { get; set; }
    }
}