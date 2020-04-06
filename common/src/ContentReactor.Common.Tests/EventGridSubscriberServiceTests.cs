namespace ContentReactor.Common.Tests
{
    using System.Collections.Generic;
    using System.IO;
    using ContentReactor.Common.EventSchemas.Audio;
    using Microsoft.AspNetCore.Http;
    using Microsoft.AspNetCore.Http.Internal;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Extensions.Primitives;
    using Newtonsoft.Json;
    using Xunit;

    /// <summary>
    /// Tests the event grid subscriber.
    /// </summary>
    public class EventGridSubscriberServiceTests
    {
        [Fact]
        public void HandleSubscriptionValidationEventReturnsValidationResponse()
        {
            // arrange
            const string requestBody = "[{\r\n  \"id\": \"2d1781af-3a4c-4d7c-bd0c-e34b19da4e66\",\r\n  \"topic\": \"/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx\",\r\n  \"subject\": \"\",\r\n  \"data\": {\r\n    \"validationCode\": \"512d38b6-c7b8-40c8-89fe-f46f9e9622b6\"\r\n  },\r\n  \"eventType\": \"Microsoft.EventGrid.SubscriptionValidationEvent\",\r\n  \"eventTime\": \"2018-01-25T22:12:19.4556811Z\",\r\n  \"metadataVersion\": \"1\",\r\n  \"dataVersion\": \"1\"\r\n}]";
            var headers = new StringValues("SubscriptionValidation");

            var service = new EventGridSubscriberService();

            // act
            var result = service.HandleSubscriptionValidationEvent(requestBody, headers);

            // assert
            Assert.NotNull(result);
            Assert.IsType<OkObjectResult>(result);
            dynamic dynamicallyTypedResult = ((OkObjectResult)result).Value;
            Assert.Equal("512d38b6-c7b8-40c8-89fe-f46f9e9622b6", (string)dynamicallyTypedResult.validationResponse);
        }

        [Fact]
        public void HandleSubscriptionValidationEventReturnsNullWhenNotSubscriptionValidationEvent()
        {
            // arrange
            const string requestBody = "[{\r\n  \"id\": \"2d1781af-3a4c-4d7c-bd0c-e34b19da4e66\",\r\n  \"topic\": \"/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx\",\r\n  \"subject\": \"\",\r\n  \"data\": {},\r\n  \"eventType\": \"Custom\",\r\n  \"eventTime\": \"2018-01-25T22:12:19.4556811Z\",\r\n  \"metadataVersion\": \"1\",\r\n  \"dataVersion\": \"1\"\r\n}]";
            var service = new EventGridSubscriberService();

            // act
            var result = service.HandleSubscriptionValidationEvent(requestBody, default);

            // assert
            Assert.Null(result);
        }

        [Fact]
        public void HandleSubscriptionValidationEventThrowsWhenInvalidJsonProvided()
        {
            // arrange
            const string requestBody = "invalidjson";
            var service = new EventGridSubscriberService();

            // act and assert
            Assert.Throws<JsonReaderException>(() => service.HandleSubscriptionValidationEvent(requestBody, default));
        }

        [Fact]
        public void DeconstructEventGridMessageParsesSingleEvent()
        {
            // arrange
            const string requestBody = "[{\r\n  \"id\": \"eventid\",\r\n  \"topic\": \"topicid\",\r\n  \"subject\": \"fakeuserid/fakeitemid\",\r\n  \"data\": {},\r\n  \"eventType\": \"AudioCreated\",\r\n  \"eventTime\": \"2018-01-25T22:12:19.4556811Z\",\r\n  \"metadataVersion\": \"1\",\r\n  \"dataVersion\": \"1\"\r\n}]";
            var service = new EventGridSubscriberService();

            // act
            (EventGridEvent eventGridEvent, string userId, string itemId) = service.DeconstructEventGridMessage(requestBody);

            // assert
            Assert.Equal("fakeuserid", userId);
            Assert.Equal("fakeitemid", itemId);
            Assert.NotNull(eventGridEvent);
            Assert.IsType<AudioCreatedEventData>(eventGridEvent.Data);
        }

        [Fact]
        public void DeconstructEventGridMessageThrowsWhenInvalidJsonProvided()
        {
            // arrange
            const string requestBody = "invalidjson";
            var service = new EventGridSubscriberService();

            // act and assert
            Assert.Throws<JsonReaderException>(() => service.DeconstructEventGridMessage(requestBody));
        }
    }
}
