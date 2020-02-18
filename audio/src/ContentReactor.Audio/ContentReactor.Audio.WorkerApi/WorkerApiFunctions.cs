using System;
using System.Threading.Tasks;
using System.Web.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Azure.WebJobs.Host;
using ContentReactor.Audio.Services;
using ContentReactor.Shared;
using ContentReactor.Shared.BlobRepository;
using ContentReactor.Shared.UserAuthentication;
using Newtonsoft.Json;

namespace ContentReactor.Audio.WorkerApi
{
    public static class WorkerApiFunctions
    {
        private const string JsonContentType = "application/json";
        private static readonly IEventGridSubscriberService EventGridSubscriberService = new EventGridSubscriberService();
        private static readonly IAudioService AudioService = new AudioService(new BlobRepository(), new AudioTranscriptionService(), new EventGridPublisherService());
        public static IUserAuthenticationService UserAuthenticationService = new QueryStringUserAuthenticationService();

        /// <summary>
        /// Performs a health check for the function.
        /// While empty now can be used to perform checks against
        /// predefined thresholds to help alert against cost overruns
        /// or certain types of client behavior that was blocked.
        /// </summary>
        /// <param name="req"></param>
        /// <param name="log"></param>
        /// <returns></returns>
        [FunctionName("HealthCheck")]
        public static async Task<IActionResult> HealthCheck(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "healthcheck")]HttpRequest req,
            TraceWriter log)
        {
            // get the user ID
            if (! await UserAuthenticationService.GetUserIdAsync(req, out var userId, out var responseResult))
            {
                return responseResult;
            }

            // list the categories
            try
            {
                var healthCheckResult = await AudioService.HealthCheckWorker(userId, req.Host.Host);
                if (healthCheckResult == null)
                {
                    return new NotFoundResult();
                }

                // serialise the summaries using a custom converter
                var settings = new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore,
                    Formatting = Formatting.Indented
                };
                var json = JsonConvert.SerializeObject(healthCheckResult, settings);

                return new ContentResult
                {
                    Content = json,
                    ContentType = JsonContentType,
                    StatusCode = StatusCodes.Status200OK
                };
            }
            catch (Exception ex)
            {
                log.Error("Unhandled exception", ex);
                return new ExceptionResult(ex, false);
            }
        }

        [FunctionName("UpdateAudioTranscript")]
        public static async Task<IActionResult> UpdateAudioTranscript(
            [HttpTrigger(AuthorizationLevel.Function, "post")]HttpRequest req,
            TraceWriter log)
        {
            // authenticate to Event Grid if this is a validation event
            var eventGridValidationOutput = EventGridSubscriberService.HandleSubscriptionValidationEvent(req);
            if (eventGridValidationOutput != null)
            {
                log.Info("Responding to Event Grid subscription verification.");
                return eventGridValidationOutput;
            }
            
            try
            {
                var (_, userId, audioId) = EventGridSubscriberService.DeconstructEventGridMessage(req);

                // update the audio transcript
                var transcriptPreview = await AudioService.UpdateAudioTranscriptAsync(audioId, userId);
                if (transcriptPreview == null)
                {
                    return new NotFoundResult();
                }

                return new OkResult();
            }
            catch (Exception ex)
            {
                log.Error("Unhandled exception", ex);
                return new ExceptionResult(ex, false);
            }
        }
    }
}
