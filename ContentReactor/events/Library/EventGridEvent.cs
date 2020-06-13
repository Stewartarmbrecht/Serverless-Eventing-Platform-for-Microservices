namespace ContentReactor.Events
{
    using System;

    /// <summary>
    /// Event grid event.
    /// </summary>
    public class EventGridEvent : EventGridEvent<object>
    {
    }

    /// <summary>
    /// Event grid event of a specfic type T.
    /// </summary>
    /// <typeparam name="T">Defines the structure for the specific event type.</typeparam>
    [System.Diagnostics.CodeAnalysis.SuppressMessage("StyleCop.CSharp.MaintainabilityRules", "SA1402:FileMayOnlyContainASingleType", Justification = "Reviewed.")]
    public class EventGridEvent<T>
    {
        /// <summary>
        /// Gets or sets the Topic for the event.
        /// </summary>
        /// <value>String.</value>
        public string Topic { get; set; }

        /// <summary>
        /// Gets or sets the Id of the event.
        /// </summary>
        /// <value>String.</value>
        public string Id { get; set; }

        /// <summary>
        /// Gets or sets the stores a string representation of the event to help with
        /// constructing a strong typed version of the event.
        /// </summary>
        /// <value>String.</value>
        public string EventType { get; set; }

        /// <summary>
        /// Gets or sets the subject of the event.
        /// Stores the item id and user id separated by a '/'.
        /// </summary>
        /// <value>String.</value>
        public string Subject { get; set; }

        /// <summary>
        /// Gets or sets the time the event occured.
        /// Does not look to be used.
        /// </summary>
        /// <value>DateTime.</value>
        public DateTime EventTime { get; set; }

        /// <summary>
        /// Gets or sets the strongly typed data of the event.
        /// </summary>
        /// <value>The strongly typed data for the event.</value>
        public T Data { get; set; }
    }
}
