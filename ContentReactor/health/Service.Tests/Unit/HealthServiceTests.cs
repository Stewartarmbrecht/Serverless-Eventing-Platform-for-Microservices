namespace ContentReactor.Health.Service.Services.Tests
{
    using System;
    using System.Collections.Generic;
    using System.Net;
    using System.Net.Http;
    using System.Text;
    using System.Threading.Tasks;
    using ContentReactor.Common.Fakes;
    using ContentReactor.Common.HealthChecks;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Moq;
    using Newtonsoft.Json;

    /// <summary>
    /// Unit test for the HealthService class.
    /// </summary>
    [TestClass]
    public class HealthServiceTests
    {
        /// <summary>
        /// Given all services are returning success health checks
        /// When you call the HealthCheckService HealthCheck operation
        /// Then you should get a collection of HealthStatusResponses for each service.
        /// </summary>
        /// <returns>Test Results.</returns>
        [TestMethod]
        public async Task HealthCheckWithSuccess()
        {
            var healthService = new HealthService();

            List<string> services = new List<string>
            {
                "test-health",
                "test-categories",
                "test-audio",
                "test-images",
                "test-text",
                "test-web",
            };

            Queue<HttpResponseMessage> responses = new Queue<HttpResponseMessage>();

            services.ForEach(serviceName =>
                {
                    var healthCheckResponse = new HealthCheckResponse()
                    {
                        Status = HealthCheckStatus.OK,
                        Application = serviceName,
                    };

                    var response = new HttpResponseMessage()
                    {
                        StatusCode = HttpStatusCode.OK,
                        Content = new StringContent(
                            JsonConvert.SerializeObject(healthCheckResponse),
                            Encoding.UTF8,
                            "application/json"),
                    };

                    responses.Enqueue(response);
                });

            var mockHttpHandler = Mockers.MockHttpMessageHandler(responses);

            HealthService.Client = new HttpClient(mockHttpHandler.Object);
            var results = await healthService.HealthCheck().ConfigureAwait(false);

            Assert.AreEqual(5, results.Count, $"There were not 5 health check statuses in the response, there were {results.Count}");
        }
    }
}
