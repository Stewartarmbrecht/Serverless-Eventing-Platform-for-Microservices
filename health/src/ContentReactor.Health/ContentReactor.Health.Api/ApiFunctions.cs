using System;
using System.IO;
using System.Threading.Tasks;
using System.Web.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Azure.WebJobs.Host;
using Newtonsoft.Json;
using ContentReactor.Shared;
using ContentReactor.Shared.UserAuthentication;
using ContentReactor.Health.Services;

namespace ContentReactor.Health.Api
{
    public static class ApiFunctions
    {
        private const string JsonContentType = "application/json";
        public static IHealthService HealthService = new HealthService();
        public static IUserAuthenticationService UserAuthenticationService = new QueryStringUserAuthenticationService();

        [FunctionName("HealthCheck")]
        public static async Task<IActionResult> HealthCheckApi(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "healthcheck")]HttpRequest req,
            TraceWriter log)
        {
            // get the text note
            try
            {
                var document = await HealthService.HealthCheck();
                if (document == null)
                {
                    return new NotFoundResult();
                }

                return new OkObjectResult(document);
            }
            catch (Exception ex)
            {
                log.Error("Unhandled exception", ex);
                return new ExceptionResult(ex, false);
            }
        }

        [FunctionName("HealthCheckTimer")]
        public static async Task HealthCheckTimer(
            [TimerTrigger("0 0/10 * * * *")]TimerInfo timer,
            TraceWriter log)
        {
            // get the text note
            try
            {
                var document = await HealthService.HealthCheck();
                if (document == null)
                {
                    log.Error("No results returned from health check.");
                }
            }
            catch (Exception ex)
            {
                log.Error("Unhandled exception", ex);
            }
        }
    }
}
