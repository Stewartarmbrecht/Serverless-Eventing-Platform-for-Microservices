namespace ContentReactor.Common
{
    using Microsoft.AspNetCore.Http;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Extensions.Primitives;

    /// <summary>
    /// Interface for subscribing to event grid events.
    /// </summary>
    public interface IEventGridSubscriberService
    {
        /// <summary>
        /// Handles the request made by the event grid to validate the subscriber end point
        /// is ready to handle calls from the event grid for publishing events.
        /// </summary>
        /// <param name="requestBody">The string value of the request body.</param>
        /// <param name="headers">The headers of the request.</param>
        /// <returns>IActionResult.</returns>
        IActionResult HandleSubscriptionValidationEvent(string requestBody, StringValues headers);

        /// <summary>
        /// Deconstructs an event grid message and pulls out the user Id and item id form the subject.
        /// </summary>
        /// <param name="requestBody">The string value of the request body.</param>
        /// <returns>Dynamic object that has the event grid event and the user Id and item Id.</returns>
        (EventGridEvent eventGridEvent, string userId, string itemId) DeconstructEventGridMessage(string requestBody);
    }
}
