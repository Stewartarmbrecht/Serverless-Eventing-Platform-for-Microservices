namespace ContentReactor.Common.Events
{
    using System;
    using System.Linq;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Extensions.Primitives;
    using Newtonsoft.Json;

    /// <summary>
    /// Service for subscribing to event grid events.
    /// </summary>
    public class EventGridSubscriberService : IEventGridSubscriberService
    {
        /// <summary>
        /// Handles the request made by the event grid to validate the subscriber end point
        /// is ready to handle calls from the event grid for publishing events.
        /// </summary>
        /// <param name="requestBody">The string value of the request body.</param>
        /// <param name="headers">The headers of the request.</param>
        /// <returns>IActionResult.</returns>
        public IActionResult HandleSubscriptionValidationEvent(string requestBody, StringValues headers)
        {
            dynamic data = JsonConvert.DeserializeObject(requestBody);

            foreach (var dataEvent in data)
            {
                if (headers.Equals("SubscriptionValidation")
                    && dataEvent.eventType == "Microsoft.EventGrid.SubscriptionValidationEvent")
                {
                    // this is a special event type that needs an echo response for Event Grid to work
                    var validationCode = dataEvent.data.validationCode; // TODO .ToString();
                    var echoResponse = new { validationResponse = validationCode };
                    return new OkObjectResult(echoResponse);
                }
            }

            return null;
        }

        /// <summary>
        /// Deconstructs an event grid message and pulls out the user Id and item id form the subject.
        /// </summary>
        /// <param name="requestBody">The string value of the request body.</param>
        /// <typeparam name="TEventData">The type that structures the event data payload.</typeparam>
        /// <returns>Dynamic object that has the event grid event and the user Id and item Id.</returns>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("StyleCop.CSharp.MaintainabilityRules", "CA1303:DoNotPassLiteralsAsLocalizedParameters", Justification = "Reviewed.")]
        public EventGridRequest<TEventData> DeconstructEventGridMessage<TEventData>(string requestBody)
        {
            // deserialise into a single Event Grid event - we won't allow multiple events to be processed
            var eventGridEvents = JsonConvert.DeserializeObject<EventGridEvent<TEventData>[]>(requestBody);
            if (eventGridEvents.Length == 0)
            {
                return null;
            }

            if (eventGridEvents.Length > 1)
            {
                throw new InvalidOperationException("Expected only a single Event Grid event.");
            }

            var eventGridEvent = eventGridEvents.Single();

            // convert the 'data' property to a strongly typed object rather than a JObject
            // eventGridEvent.Data = this.CreateStronglyTypedDataObject(eventGridEvent.Data, eventGridEvent.EventType);

            // find the user ID and item ID from the subject
            var eventGridEventSubjectComponents = eventGridEvent.Subject.Split('/');
            if (eventGridEventSubjectComponents.Length != 2)
            {
                throw new InvalidOperationException("Event Grid event subject is not in expected format.");
            }

            var eventGridRequest = new EventGridRequest<TEventData>()
            {
                UserId = eventGridEventSubjectComponents[0],
                ItemId = eventGridEventSubjectComponents[1],
                Event = eventGridEvent,
            };

            return eventGridRequest;
        }
    }
}
