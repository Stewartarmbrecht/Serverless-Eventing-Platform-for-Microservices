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
    /// Contains the operation for beginning the add of an audio file.
    /// </summary>
    public partial class Functions
    {
        /// <summary>
        /// Performs a health check for the function.
        /// While empty now can be used to perform checks against
        /// predefined thresholds to help alert against cost overruns
        /// or certain types of client behavior that was blocked.
        /// </summary>
        /// <param name="req">Request sent to the azure function.</param>
        /// <param name="log">Logger to use for logging information or errors.</param>
        /// <returns>Results of the health check.</returns>
        [FunctionName("HealthCheck")]
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1062", Justification = "Reviewed")]
        public async Task<IActionResult> HealthCheck(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "healthcheck")] HttpRequest req,
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

                var healthCheckResponse = new HealthCheckResponse()
                {
                    Status = HealthCheckStatus.OK,
                    Application = req.Host.Host,
                };

                return new OkObjectResult(healthCheckResponse);
            }
            catch (Exception ex)
            {
                log.LogError(ex, UnhandledExceptionError);
                throw;
            }
        }
    }
}
