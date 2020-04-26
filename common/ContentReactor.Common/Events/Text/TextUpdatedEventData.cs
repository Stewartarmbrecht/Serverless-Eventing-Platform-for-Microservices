namespace ContentReactor.Common.Events.Text
{
    /// <summary>
    /// Event raised when a text item is updated.
    /// </summary>
    public class TextUpdatedEventData
    {
        /// <summary>
        /// Gets or sets the preview of the updated text note.
        /// </summary>
        /// <value>String.</value>
        public string Preview { get; set; }
    }
}