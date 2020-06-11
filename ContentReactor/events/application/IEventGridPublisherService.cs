namespace ContentReactor.Events
{
    using System.Threading.Tasks;

    /// <summary>
    /// Interface for posting a event to the event grid.
    /// </summary>
    public interface IEventGridPublisherService
    {
        /// <summary>
        /// Posts an event to the event grid service.
        /// </summary>
        /// <param name="type">Type of the event.</param>
        /// <param name="subject">Subject of the event.</param>
        /// <param name="payload">Payload for the event.</param>
        /// <typeparam name="T">Type of the payload.</typeparam>
        /// <returns>Void.</returns>
        Task PostEventGridEventAsync<T>(string type, string subject, T payload);
    }
}