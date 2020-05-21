namespace ContentReactor.Categories.Tests.UnitTests
{
    using System;
    using System.IO;
    using System.Net;
    using System.Net.Http;
    using System.Reflection;
    using System.Threading;
    using System.Threading.Tasks;
    using ContentReactor.Categories.Services;
    using Microsoft.VisualStudio.TestTools.UnitTesting;

    /// <summary>
    /// Tests the Image Search Service.
    /// </summary>
    public class ImageSearchServiceTests
    {
        /// <summary>
        /// Given you have a valid search term that matches to an image
        /// When you call the FindImageUrlAsync operation
        /// Then you should get a url to the image.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task FindImageUrlReturnsExpectedUrl()
        {
            // arrange
            Environment.SetEnvironmentVariable("CognitiveServicesSearchApiEndpoint", "https://fake/");
            Environment.SetEnvironmentVariable("CognitiveServicesSearchApiKey", "tempkey");
            var service = new ImageSearchService(
                new HttpClient(new MockHttpMessageHandler(GetFileResourceString("1.json"))));

            // act
            var result = await service.FindImageUrlAsync("searchterm").ConfigureAwait(false);

            // assert
            Assert.AreEqual("http://images2.fanpop.com/image/photos/9400000/Funny-Cats-cats-9473312-1600-1200.jpg", result);
        }

        /// <summary>
        /// Given you have a search term that does not match to an image
        /// When you call the FindImageUrlAsync operation
        /// Then you should get a null value returned.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task FindImageUrlReturnsNull()
        {
            // arrange
            Environment.SetEnvironmentVariable("CognitiveServicesSearchApiEndpoint", "https://fake/");
            Environment.SetEnvironmentVariable("CognitiveServicesSearchApiKey", "tempkey");
            var service = new ImageSearchService(
                new HttpClient(new MockHttpMessageHandler(GetFileResourceString("0.json"))));

            // act
            var result = await service.FindImageUrlAsync("searchterm").ConfigureAwait(false);

            // assert
            Assert.IsNull(result);
        }

        private static string GetFileResourceString(string filename)
        {
            var assembly = Assembly.GetExecutingAssembly();
            var resourceName = $"ContentReactor.Categories.Tests.ImageSearchServiceSampleResponses.{filename}";
            var stream = assembly.GetManifestResourceStream(resourceName);
            using var reader = new StreamReader(stream, System.Text.Encoding.UTF8);
            return reader.ReadToEnd();
        }

        private class MockHttpMessageHandler : HttpMessageHandler
        {
            private readonly string response;

            public MockHttpMessageHandler(string response)
            {
                this.response = response;
            }

            protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
            {
                var responseMessage = new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(this.response)
                };

                return await Task.FromResult(responseMessage).ConfigureAwait(false);
            }
        }
    }
}
