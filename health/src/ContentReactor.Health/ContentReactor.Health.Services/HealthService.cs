using System;
using System.Threading.Tasks;
using ContentReactor.Shared;
using System.Net.Http;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;


namespace ContentReactor.Health.Services
{
    /// <summary>
    /// Interface for the health check service.
    /// </summary>
    public interface IHealthService
    {
        /// <summary>
        /// Performs health checks on all applications in the system.
        /// </summary>
        /// <returns></returns>
        Task<List<HealthCheckResults>> HealthCheck();
    }

    /// <summary>
    /// Performs health checks on a scheduled basis.
    /// </summary>
    public class HealthService : IHealthService
    {
        static string systemNamePrefix = Environment.GetEnvironmentVariable("SYSTEM_NAME_PREFIX", EnvironmentVariableTarget.Process);
        static HttpClient client = new HttpClient();
        public async Task<List<HealthCheckResults>> HealthCheck()
        {
            List<HealthCheckResults> results = new List<HealthCheckResults>();

            List<string> urls = new List<string>();
            //urls.Add($"http://{systemNamePrefix}-audio-api.azurewebsites.net/api/healthcheck");
            //urls.Add($"http://{systemNamePrefix}-audio-worker.azurewebsites.net/api/healthcheck");
            urls.Add($"https://{systemNamePrefix}-categories-api.azurewebsites.net/api/healthcheck?userId={systemNamePrefix}");
            urls.Add($"https://{systemNamePrefix}-categories-worker.azurewebsites.net/api/healthcheck?userId={systemNamePrefix}");
            //urls.Add($"http://{systemNamePrefix}-images-api.azurewebsites.net/api/healthcheck");
            //urls.Add($"http://{systemNamePrefix}-images-worker.azurewebsites.net/api/healthcheck");
            //urls.Add($"http://{systemNamePrefix}-proxy-api.azurewebsites.net/api/healthcheck");
            //urls.Add($"http://{systemNamePrefix}-text-api.azurewebsites.net/api/healthcheck");
            //urls.Add($"http://{systemNamePrefix}-web-app.azurewebsites.net/api/healthcheck");

            List<Task<HttpResponseMessage>> tasks = new List<Task<HttpResponseMessage>>();

            urls.ForEach(url => {
                tasks.Add(client.GetAsync(url));
            });

            Task.WaitAll(tasks.ToArray());

            List<Task<HealthCheckResults>> healthChechResultsTasks = new List<Task<HealthCheckResults>>();

            tasks.ForEach(task => {
                healthChechResultsTasks.Add(task.Result.Content.ReadAsAsync<HealthCheckResults>());
            });

            var healthCheckResultsSet = await Task.WhenAll<HealthCheckResults>(healthChechResultsTasks.ToArray());

            foreach(var healthCheckResults in healthCheckResultsSet.OrderBy(x => x.Application)) {
                results.Add(healthCheckResults);
            }

            return results;

        }
    }
}
