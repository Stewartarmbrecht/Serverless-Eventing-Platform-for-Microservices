namespace ContentReactor.Common
{
    using System;
    using System.Linq;
    using ContentReactor.Common.EventSchemas.Audio;
    using ContentReactor.Common.EventSchemas.Categories;
    using ContentReactor.Common.EventSchemas.Images;
    using ContentReactor.Common.EventSchemas.Text;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Extensions.Primitives;
    using Newtonsoft.Json;
    using Newtonsoft.Json.Linq;

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
        /// <returns>Dynamic object that has the event grid event and the user Id and item Id.</returns>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("StyleCop.CSharp.MaintainabilityRules", "CA1303:DoNotPassLiteralsAsLocalizedParameters", Justification = "Reviewed.")]
        public (EventGridEvent eventGridEvent, string userId, string itemId) DeconstructEventGridMessage(string requestBody)
        {
            // deserialise into a single Event Grid event - we won't allow multiple events to be processed
            var eventGridEvents = JsonConvert.DeserializeObject<EventGridEvent[]>(requestBody);
            if (eventGridEvents.Length == 0)
            {
                return (null, null, null);
            }

            if (eventGridEvents.Length > 1)
            {
                throw new InvalidOperationException("Expected only a single Event Grid event.");
            }

            var eventGridEvent = eventGridEvents.Single();

            // convert the 'data' property to a strongly typed object rather than a JObject
            eventGridEvent.Data = this.CreateStronglyTypedDataObject(eventGridEvent.Data, eventGridEvent.EventType);

            // find the user ID and item ID from the subject
            var eventGridEventSubjectComponents = eventGridEvent.Subject.Split('/');
            if (eventGridEventSubjectComponents.Length != 2)
            {
                throw new InvalidOperationException("Event Grid event subject is not in expected format.");
            }

            var userId = eventGridEventSubjectComponents[0];
            var itemId = eventGridEventSubjectComponents[1];

            return (eventGridEvent, userId, itemId);
        }

        private object CreateStronglyTypedDataObject(object data, string eventType)
        {
            object result = eventType switch
            {
                // creates
                EventTypes.AudioEvents.AudioCreated => this.ConvertDataObjectToType<AudioCreatedEventData>(data),
                EventTypes.CategoryEvents.CategoryCreated => this.ConvertDataObjectToType<CategoryCreatedEventData>(data),
                EventTypes.ImageEvents.ImageCreated => this.ConvertDataObjectToType<ImageCreatedEventData>(data),
                EventTypes.TextEvents.TextCreated => this.ConvertDataObjectToType<TextCreatedEventData>(data),

                // updates
                EventTypes.AudioEvents.AudioTranscriptUpdated => this.ConvertDataObjectToType<AudioTranscriptUpdatedEventData>(data),
                EventTypes.CategoryEvents.CategoryImageUpdated => this.ConvertDataObjectToType<CategoryImageUpdatedEventData>(data),
                EventTypes.CategoryEvents.CategoryItemsUpdated => this.ConvertDataObjectToType<CategoryItemsUpdatedEventData>(data),
                EventTypes.CategoryEvents.CategoryNameUpdated => this.ConvertDataObjectToType<CategoryNameUpdatedEventData>(data),
                EventTypes.CategoryEvents.CategorySynonymsUpdated => this.ConvertDataObjectToType<CategorySynonymsUpdatedEventData>(data),
                EventTypes.ImageEvents.ImageCaptionUpdated => this.ConvertDataObjectToType<ImageCaptionUpdatedEventData>(data),
                EventTypes.TextEvents.TextUpdated => this.ConvertDataObjectToType<TextUpdatedEventData>(data),

                // deletes
                EventTypes.AudioEvents.AudioDeleted => this.ConvertDataObjectToType<AudioDeletedEventData>(data),
                EventTypes.CategoryEvents.CategoryDeleted => this.ConvertDataObjectToType<CategoryDeletedEventData>(data),
                EventTypes.ImageEvents.ImageDeleted => this.ConvertDataObjectToType<ImageDeletedEventData>(data),
                EventTypes.TextEvents.TextDeleted => this.ConvertDataObjectToType<TextDeletedEventData>(data),
                _ => null,
            };

            if (result == null)
            {
                throw new ArgumentException($"Unexpected event type '{eventType}' in {nameof(this.CreateStronglyTypedDataObject)}");
            }
            else
            {
                return result;
            }
        }

        private T ConvertDataObjectToType<T>(object dataObject)
        {
            if (dataObject is JObject o)
            {
                return o.ToObject<T>();
            }

            return (T)dataObject;
        }
    }
}
