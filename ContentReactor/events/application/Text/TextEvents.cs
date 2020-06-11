namespace ContentReactor.Events.Text
{
    /// <summary>
    /// Events for text.
    /// </summary>
    public static class TextEvents
    {
        /// <summary>
        /// Type for an event when a text note is created.
        /// </summary>
        /// <returns>String.</returns>
        public const string TextCreated = nameof(TextCreated);

        /// <summary>
        /// Type for an event when a text note is deleted.
        /// </summary>
        /// <returns>String.</returns>
        public const string TextDeleted = nameof(TextDeleted);

        /// <summary>
        /// Type for an event when a text note is updated.
        /// </summary>
        /// <returns>String.</returns>
        public const string TextUpdated = nameof(TextUpdated);
    }
}