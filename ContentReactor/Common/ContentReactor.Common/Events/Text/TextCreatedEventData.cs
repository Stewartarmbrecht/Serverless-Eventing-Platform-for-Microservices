namespace ContentReactor.Common.Events.Text
{
    /// <summary>
    /// Event raised when text is created.
    /// </summary>
    public class TextCreatedEventData
    {
        /// <summary>
        /// Gets or sets the truncated preview for the created text note.
        /// </summary>
        /// <value>String.</value>
        public string Preview { get; set; }

        /// <summary>
        /// Gets or sets the category for the new text note.
        /// </summary>
        /// <value>String.</value>
        public string Category { get; set; }
    }
}