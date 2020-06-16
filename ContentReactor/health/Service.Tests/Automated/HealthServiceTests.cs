namespace ContentReactor.Audio.Service.Tests.Automated
{
    using System;
    using System.Diagnostics.CodeAnalysis;
    using System.Net.Http;
    using System.Threading.Tasks;
    using ContentReactor.Audio.Service;
    using ContentReactor.Common.HealthChecks;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Newtonsoft.Json;

    /// <summary>
    /// Contains end to end tests for the Health service.
    /// </summary>
    [TestClass]
    [TestCategory("Automated")]
    public class HealthServiceTests
    {
        private static readonly HttpClient HttpClientInstance = new HttpClient();
        private readonly string baseUrl = Environment.GetEnvironmentVariable("AutomatedUrl");
        private readonly string defaultUserId = "developer@edentest.com";

        /// <summary>
        /// Given you have a health service
        /// When you call the health check function
        /// Then you should get back a positive status.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task GetHealthCheckWithSuccess()
        {
            var healthCheckResponse = await this.GetHealthCheck().ConfigureAwait(false);
            Assert.AreEqual(HealthCheckStatus.OK, healthCheckResponse.Status, $"The status was not '0'.  It was '{healthCheckResponse.Status}'");
            Assert.IsTrue(this.baseUrl.Contains(healthCheckResponse.Application, System.StringComparison.CurrentCultureIgnoreCase), $"The baseUrl '{this.baseUrl}' did not contain '{healthCheckResponse.Application}'.");
        }

        private async Task<HealthCheckResponse> GetHealthCheck(string userId = null)
        {
            userId ??= this.defaultUserId;
            Uri getUrl = new Uri($"{this.baseUrl}/healthcheck?userId={userId}");
            var getResponse = await HttpClientInstance.GetAsync(getUrl).ConfigureAwait(false);
            var getResponseContent = await getResponse.Content.ReadAsStringAsync().ConfigureAwait(false);
            HealthCheckResponse getResponseBody =
                JsonConvert.DeserializeObject<HealthCheckResponse>(getResponseContent);
            return getResponseBody;
        }
    }
}