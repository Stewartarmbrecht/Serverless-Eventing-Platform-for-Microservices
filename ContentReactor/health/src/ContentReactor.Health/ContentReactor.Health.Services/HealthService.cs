using System;
using System.Threading.Tasks;
using ContentReactor.Common;
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
        static string systemsystemName = Environment.GetEnvironmentVariable("SYSTEM_NAME_PREFIX", EnvironmentVariableTarget.Process);
        static HttpClient client = new HttpClient();
        public async Task<List<HealthCheckResults>> HealthCheck()
        {
            List<HealthCheckResults> results = new List<HealthCheckResults>();

            List<string> urls = new List<string>();
            urls.Add($"https://{systemsystemName}-proxy-api.azurewebsites.net/audiohealthcheck?userId={systemsystemName}");
            urls.Add($"https://{systemsystemName}-audio-worker.azurewebsites.net/api/healthcheck?userId={systemsystemName}");
            urls.Add($"https://{systemsystemName}-proxy-api.azurewebsites.net/categorieshealthcheck?userId={systemsystemName}");
            urls.Add($"https://{systemsystemName}-categories-worker.azurewebsites.net/api/healthcheck?userId={systemsystemName}");
            urls.Add($"https://{systemsystemName}-proxy-api.azurewebsites.net/imageshealthcheck?userId={systemsystemName}");
            urls.Add($"https://{systemsystemName}-images-worker.azurewebsites.net/api/healthcheck?userId={systemsystemName}");
            urls.Add($"https://{systemsystemName}-proxy-api.azurewebsites.net/texthealthcheck?userId={systemsystemName}");
            urls.Add($"https://{systemsystemName}-web-app.azurewebsites.net/api/health?userId={systemsystemName}");

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
