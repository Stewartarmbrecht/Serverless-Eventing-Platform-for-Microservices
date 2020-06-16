namespace ContentReactor.Health.Service
{
    using System;
    using System.Threading.Tasks;
    using ContentReactor.Common.HealthChecks;
    using Microsoft.AspNetCore.Http;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Azure.WebJobs;
    using Microsoft.Azure.WebJobs.Extensions.Http;
    using Microsoft.Extensions.Logging;
    using Newtonsoft.Json;

    /// <summary>
    /// Contains the operation for performing a system wide health check.
    /// </summary>
    public partial class Functions
    {
        /// <summary>
        /// Performs a health check against all services.
        /// </summary>
        /// <param name="req">Request sent to the azure function.</param>
        /// <param name="log">Logger to use for logging information or errors.</param>
        /// <returns>Results of the health check.</returns>
        [FunctionName("SystemHealthCheck")]
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1062", Justification = "Reviewed")]
        public async Task<IActionResult> SystemHealthCheck(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "systemhealthcheck")] HttpRequest req,
            ILogger log)
        {
            // list the categories
            try
            {
                // get the user ID
                if (!await this.UserAuthenticationService.GetUserIdAsync(req, out var userId, out var responseResult).ConfigureAwait(false))
                {
                    return responseResult;
                }

                var document = await this.HealthService.HealthCheck().ConfigureAwait(false);
                if (document == null)
                {
                    log.LogError("No results returned from health check.");
                }

                return new OkObjectResult(document);
            }
            catch (Exception ex)
            {
                log.LogError(UnhandledExceptionError, ex);
                throw;
            }
        }
    }
}
