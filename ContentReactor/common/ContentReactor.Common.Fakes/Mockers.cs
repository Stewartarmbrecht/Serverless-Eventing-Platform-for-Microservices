namespace ContentReactor.Common.Fakes
{
    using System.Collections.Generic;
    using System.IO;
    using System.Net;
    using System.Net.Http;
    using System.Runtime.Serialization;
    using System.Runtime.Serialization.Formatters.Binary;
    using System.Threading;
    using System.Threading.Tasks;
    using ContentReactor.Common.UserAuthentication;
    using Microsoft.AspNetCore.Http;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Azure.WebJobs;
    using Microsoft.Azure.WebJobs.Extensions.Timers;
    using Moq;
    using Moq.Protected;
    using Newtonsoft.Json;

    /// <summary>
    /// Utility methods for creating mocks to test http triggered functions.
    /// </summary>
    public static class Mockers
    {
        /// <summary>
        /// Gets the default user id to mock during testing.
        /// </summary>
        /// <value>The default user id that is mocked during testing.</value>
        public const string DefaultUserId = "fakeuserid";

        /// <summary>x
        /// Gets the default id to mock during testing.
        /// </summary>
        /// <value>The default id that is mocked during testing.</value>
        public const string DefaultId = "fakeid";

        /// <summary>x
        /// Gets the default category id to mock during testing.
        /// </summary>
        /// <value>The default category id that is mocked during testing.</value>
        public const string DefaultCategoryId = "fakecategoryid";

        /// <summary>
        /// Gets the container name for the Audio blob service.
        /// </summary>
        /// <value>The audio container name.</value>
        public const string AudioContainerName = "audio";

        /// <summary>
        /// Gets the default category name.
        /// </summary>
        /// <value>The audio container name.</value>
        public const string DefaultCategoryName = "Test";

        /// <summary>
        /// Name of meta data field that holds the transcript.
        /// </summary>
        public const string TranscriptMetadataName = "transcript";

        /// <summary>
        /// Id of the category the audio file is organized under.
        /// </summary>
        public const string CategoryIdMetadataName = "categoryId";

        /// <summary>
        /// Name of the metadata field that holds the user id.
        /// </summary>
        public const string UserIdMetadataName = "userId";

        /// <summary>
        /// Length of the transcript preview.
        /// </summary>
        public const int TranscriptPreviewLength = 100;

        /// <summary>
        /// Creates a stream for an object.
        /// </summary>
        /// <param name="o">The object to stream.</param>
        /// <returns>A Memory stream of the object.</returns>
        public static MemoryStream SerializeToStream(object o)
        {
            MemoryStream stream = new MemoryStream();
            IFormatter formatter = new BinaryFormatter();
            formatter.Serialize(stream, o);
            return stream;
        }

        /// <summary>
        /// Mocks a request that has a request body to stream.
        /// </summary>
        /// <param name="requestBody">The object to stream as the body.</param>
        /// <param name="headerDictionary">The dictionary of headers to include in the request.</param>
        /// <returns>A mock http request object.</returns>
        public static Mock<HttpRequest> MockRequest(object requestBody, IHeaderDictionary headerDictionary)
        {
            var mockRequest = MockRequest(requestBody);
            mockRequest.Setup(x => x.Headers).Returns(headerDictionary);
            return mockRequest;
        }

        /// <summary>
        /// Mocks a request that has a request body to stream.
        /// </summary>
        /// <param name="requestBody">The object to stream as the body.</param>
        /// <returns>A mock http request object.</returns>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Reliability", "CA2000", Justification = "Reviewed")]
        public static Mock<HttpRequest> MockRequest(object requestBody)
        {
            var mockRequest = new Mock<HttpRequest>();

            if (requestBody != null)
            {
                var ms = new MemoryStream();

                // using statement below might cause tests to fail.
                var sw = new StreamWriter(ms);

                var json = JsonConvert.SerializeObject(requestBody);

                sw.Write(json);
                sw.Flush();

                ms.Position = 0;

                mockRequest.Setup(x => x.Body).Returns(ms);
            }

            return mockRequest;
        }

        /// <summary>
        /// Mocks a request that has invalid json.
        /// </summary>
        /// <returns>A mock http request object.</returns>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Reliability", "CA2000", Justification = "Reviewed")]
        public static Mock<HttpRequest> MockRequestWithInvalidJson()
        {
            var mockRequest = new Mock<HttpRequest>();

            var ms = new MemoryStream();
            var sw = new StreamWriter(ms);

            sw.Write("this is invalid json.");
            sw.Flush();

            ms.Position = 0;

            mockRequest.Setup(x => x.Body).Returns(ms);
            return mockRequest;
        }

        /// <summary>
        /// Mocks a request that has invalid json.
        /// </summary>
        /// <returns>A mock http request object.</returns>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Reliability", "CA2000", Justification = "Reviewed")]
        public static Mock<HttpRequest> MockRequestWithNoPayload()
        {
            var mockRequest = new Mock<HttpRequest>();

            var ms = new MemoryStream();
            var sw = new StreamWriter(ms);

            sw.Flush();

            ms.Position = 0;

            mockRequest.Setup(x => x.Body).Returns(ms);
            return mockRequest;
        }

        /// <summary>
        /// Mocks the user authentication service.
        /// </summary>
        /// <returns>Mock user authentication service that returns "fakeuserid" for the user id and true for the results.</returns>
        public static Mock<IUserAuthenticationService> MockUserAuth()
        {
            var mockUserAuth = new Mock<IUserAuthenticationService>();
            var mockResult = new Mock<IActionResult>();
            var mockResultObject = mockResult.Object;
            var userId = "fakeuserid";
            mockUserAuth.Setup(m => m.GetUserIdAsync(It.IsAny<HttpRequest>(), out userId, out mockResultObject)).ReturnsAsync(true);
            return mockUserAuth;
        }

        /// <summary>
        /// Mocks an HttpMessageHandler to rertun a response for any request.
        /// </summary>
        /// <param name="responses">The object to JSON serialize as the content of the response.</param>
        /// <returns>HttpMessageHandler mock that will return a set response for any request.</returns>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Reliability", "CA2000", Justification = "Reviewed")]
        public static Mock<HttpMessageHandler> MockHttpMessageHandler(Queue<HttpResponseMessage> responses)
        {
            var handlerMock = new Mock<HttpMessageHandler>(MockBehavior.Strict);
            handlerMock.Protected()

                // Setup the PROTECTED method to mock
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>())

                // prepare the expected response of the mocked http call
                .ReturnsAsync(() => responses.Dequeue())
                .Verifiable();

            return handlerMock;
        }

        /// <summary>
        /// Returns a TimerInfo object to use to call Timer based azure functions.
        /// </summary>
        /// <returns>An instance of the <see class="TimerInfo"/> class.</returns>
        public static TimerInfo GetTimerInfo()
        {
            return new TimerInfo(new ScheduleStub(), new ScheduleStatus(), false);
        }
    }
}