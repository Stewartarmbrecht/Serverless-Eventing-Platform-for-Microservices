namespace ContentReactor.Common.Events
{
    /// <summary>
    /// Event grid request.
    /// </summary>
    public class EventGridRequest : EventGridRequest<object>
    {
    }

    /// <summary>
    /// Represents the body of an event grid request.
    /// </summary>
    /// <typeparam name="TEventData">Type that defines the structure of the event data.</typeparam>
    [System.Diagnostics.CodeAnalysis.SuppressMessage("StyleCop.CSharp.MaintainabilityRules", "SA1402:FileMayOnlyContainASingleType", Justification = "Reviewed.")]
    public class EventGridRequest<TEventData>
    {
        /// <summary>
        /// Gets or sets the User id for the message.
        /// </summary>
        /// <value>The id of the user that triggered the event.</value>
        public string UserId { get; set; }

        /// <summary>
        /// Gets or sets the item id for the message.
        /// </summary>
        /// <value>The id of the user that triggered the event.</value>
        public string ItemId { get; set; }

        /// <summary>
        /// Gets or sets the details of the event grid event.
        /// </summary>
        /// <value>An instance of the <see cref="EventGridEvent"/> class.</value>
        public EventGridEvent<TEventData> Event { get; set; }
    }
}
