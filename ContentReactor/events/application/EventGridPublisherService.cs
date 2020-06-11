namespace ContentReactor.Events
{
    using System;
    using System.Collections.Generic;
    using System.Threading.Tasks;
    using Microsoft.Azure.EventGrid;
    using Microsoft.Azure.EventGrid.Models;

    /// <summary>
    /// Service for publishing events to the event grid service.
    /// </summary>
    public class EventGridPublisherService : IEventGridPublisherService
    {
        /// <summary>
        /// Posts an event to the event grid service.
        /// </summary>
        /// <param name="type">Type of the event.</param>
        /// <param name="subject">Subject of the event.</param>
        /// <param name="payload">Payload for the event.</param>
        /// <typeparam name="T">Type of the payload.</typeparam>
        /// <returns>Void.</returns>
        public Task PostEventGridEventAsync<T>(string type, string subject, T payload)
        {
            // get the connection details for the Event Grid topic
            var topicEndpointUri = new Uri(Environment.GetEnvironmentVariable("EventGridTopicEndpoint"));
            var topicEndpointHostname = topicEndpointUri.Host;
            var topicKey = Environment.GetEnvironmentVariable("EventGridTopicKey");
            var topicCredentials = new TopicCredentials(topicKey);

            // prepare the events for submission to Event Grid
            var events = new List<Microsoft.Azure.EventGrid.Models.EventGridEvent>
            {
                new Microsoft.Azure.EventGrid.Models.EventGridEvent
                {
                    Id = Guid.NewGuid().ToString(),
                    EventType = type,
                    Subject = subject,
                    EventTime = DateTime.UtcNow,
                    Data = payload,
                    DataVersion = "1",
                },
            };

            // publish the events
            using var client = new EventGridClient(topicCredentials);
            return client.PublishEventsWithHttpMessagesAsync(topicEndpointHostname, events);
        }
    }
}
