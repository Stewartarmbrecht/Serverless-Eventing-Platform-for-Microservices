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
    /// Tests the Synonym service.
    /// </summary>
    [TestClass]
    public class SynonymServiceTests
    {
        /// <summary>
        /// Given you have a search term that has synonyms
        /// When you call the FindImageUrlAsync operation
        /// Then you should get a list of synonyms.
        /// </summary>
        /// <returns>A task to run test.</returns>
         [TestMethod]
        public async Task GetSynonymsReturnsSynonyms()
        {
            // arrange
            Environment.SetEnvironmentVariable("BigHugeThesaurusApiEndpoint", "https://fake/");
            Environment.SetEnvironmentVariable("BigHugeThesaurusApiKey", "tempkey");
            var service = new SynonymService(
                new HttpClient(new MockHttpMessageHandler(GetFileResourceString("sample.json"))));

            // act
            var result = await service.GetSynonymsAsync("searchterm").ConfigureAwait(false);

            // assert
            Assert.AreEqual(67, result.Count);
        }

        /// <summary>
        /// Given you have a search term that does not have synonyms
        /// When you call the FindImageUrlAsync operation
        /// Then you should get a null value returned.
        /// </summary>
        /// <returns>A task to run test.</returns>
         [TestMethod]
        public async Task GetSynonymsReturnsNull()
        {
            // arrange
            Environment.SetEnvironmentVariable("BigHugeThesaurusApiEndpoint", "https://fake/");
            Environment.SetEnvironmentVariable("BigHugeThesaurusApiKey", "tempkey");
            var service = new SynonymService(new HttpClient(new NotFoundHttpMessageHandler()));

            // act
            var result = await service.GetSynonymsAsync("searchterm").ConfigureAwait(false);

            // assert
            Assert.IsNull(result);
        }

        private static string GetFileResourceString(string filename)
        {
            var assembly = Assembly.GetExecutingAssembly();
            var resourceName = $"ContentReactor.Categories.Tests.SynonymServiceSampleResponses.{filename}";
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

        private class NotFoundHttpMessageHandler : HttpMessageHandler
        {
            protected override async Task<HttpResponseMessage> SendAsync(
                HttpRequestMessage request,
                CancellationToken cancellationToken) =>
                    await Task.FromResult(new HttpResponseMessage(HttpStatusCode.NotFound)).ConfigureAwait(false);
        }
    }
}
