namespace ContentReactor.Health.Service
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Net.Http;
    using System.Threading.Tasks;
    using ContentReactor.Common.HealthChecks;

    /// <summary>
    /// Performs health checks on a scheduled basis.
    /// </summary>
    public class HealthService : IHealthService
    {
        private static readonly string InstanceName = Environment.GetEnvironmentVariable("SYSTEM_NAME_PREFIX", EnvironmentVariableTarget.Process);

        /// <summary>
        /// Gets or sets the Http client for calling health check functions.
        /// </summary>
        /// <returns>An instance of the <see class="HttpClient"/> class.</returns>
        public static HttpClient Client { get; set; }

        /// <summary>
        /// Calls the HealthCheck function for each service.
        /// </summary>
        /// <returns>Compiled results of each HealthCheck call.</returns>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Performance", "CA1822: Mark members as static", Justification = "Reviewed")]
        public async Task<List<HealthCheckResponse>> HealthCheck()
        {
            List<HealthCheckResponse> results = new List<HealthCheckResponse>();

            List<string> urls = new List<string>
            {
                $"https://{InstanceName}-api.azurewebsites.net/categorieshealthcheck?userId={InstanceName}",
                $"https://{InstanceName}-api.azurewebsites.net/audiohealthcheck?userId={InstanceName}",
                $"https://{InstanceName}-api.azurewebsites.net/imageshealthcheck?userId={InstanceName}",
                $"https://{InstanceName}-api.azurewebsites.net/texthealthcheck?userId={InstanceName}",
                $"https://{InstanceName}-web-app.azurewebsites.net/api/health?userId={InstanceName}",
            };

            List<Task<HttpResponseMessage>> tasks = new List<Task<HttpResponseMessage>>();

            urls.ForEach(url => tasks.Add(Client.GetAsync(new Uri(url))));

            Task.WaitAll(tasks.ToArray());

            List<Task<HealthCheckResponse>> healthChechResultsTasks = new List<Task<HealthCheckResponse>>();

            tasks.ForEach(task => healthChechResultsTasks.Add(task.Result.Content.ReadAsAsync<HealthCheckResponse>()));

            var healthCheckResultsSet = await Task.WhenAll<HealthCheckResponse>(healthChechResultsTasks.ToArray()).ConfigureAwait(false);

            foreach (var healthCheckResults in healthCheckResultsSet.OrderBy(x => x.Application))
            {
                results.Add(healthCheckResults);
            }

            return results;
        }
    }
}
