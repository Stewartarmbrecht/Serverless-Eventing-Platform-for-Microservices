namespace ContentReactor.Events.Categories
{
    /// <summary>
    /// Lists all Categories events.
    /// </summary>
    public static class CategoryEvents
    {
        /// <summary>
        /// Type for an event when a category is created.
        /// </summary>
        /// <returns>String.</returns>
        public const string CategoryCreated = nameof(CategoryCreated);

        /// <summary>
        /// Type for an event when a category is deleted.
        /// </summary>
        /// <returns>String.</returns>
        public const string CategoryDeleted = nameof(CategoryDeleted);

        /// <summary>
        /// Type for an event when a category name is updated.
        /// </summary>
        /// <returns>String.</returns>
        public const string CategoryNameUpdated = nameof(CategoryNameUpdated);

        /// <summary>
        /// Type for an event when a category image is updated.
        /// </summary>
        /// <returns>String.</returns>
        public const string CategoryImageUpdated = nameof(CategoryImageUpdated);

        /// <summary>
        /// Type for an event when a category's synonyms are updated.
        /// </summary>
        /// <returns>String.</returns>
        public const string CategorySynonymsUpdated = nameof(CategorySynonymsUpdated);

        /// <summary>
        /// Type for an event when a category's items are updated.
        /// </summary>
        /// <returns>String.</returns>
        public const string CategoryItemsUpdated = nameof(CategoryItemsUpdated);
    }
}