namespace ContentReactor.Audio.WorkerApi
{
    using System;
    using System.IO;
    using System.Threading.Tasks;
    using ContentReactor.Audio.Services;
    using ContentReactor.Common;
    using ContentReactor.Common.Blobs;
    using ContentReactor.Common.UserAuthentication;
    using Microsoft.AspNetCore.Http;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Azure.WebJobs;
    using Microsoft.Azure.WebJobs.Extensions.Http;
    using Microsoft.Extensions.Logging;
    using Microsoft.Extensions.Primitives;
    using Newtonsoft.Json;

    /// <summary>
    /// Service that processes audio events.
    /// Provides API called by the event grid to process events audio events.
    /// </summary>
    public static class WorkerApiFunctions
    {
        private const string EventGridSubscriptionValidationHeaderKey = "Aeg-Event-Type";
        private const string JsonContentType = "application/json";
        private const string UnhandledExceptionError = "Unhandled Exception.";
        private static readonly IEventGridSubscriberService EventGridSubscriberService = new EventGridSubscriberService();
        private static readonly IAudioService AudioService = new AudioService(new BlobRepository(), new AudioTranscriptionService(), new EventGridPublisherService());
        private static readonly IUserAuthenticationService UserAuthenticationService = new QueryStringUserAuthenticationService();

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
        public static async Task<IActionResult> HealthCheck(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "healthcheck")]HttpRequest req,
            ILogger log)
        {
            if (req == null)
            {
                throw new ArgumentNullException(nameof(req));
            }

            // get the user ID
            if (!await UserAuthenticationService.GetUserIdAsync(req, out var userId, out var responseResult).ConfigureAwait(false))
            {
                return responseResult;
            }

            // list the categories
            try
            {
                var healthCheckResult = await AudioService.HealthCheckWorker(userId, req.Host.Host).ConfigureAwait(false);
                if (healthCheckResult == null)
                {
                    return new NotFoundResult();
                }

                // serialise the summaries using a custom converter
                var settings = new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore,
                    Formatting = Formatting.Indented,
                };
                var json = JsonConvert.SerializeObject(healthCheckResult, settings);

                return new ContentResult
                {
                    Content = json,
                    ContentType = JsonContentType,
                    StatusCode = StatusCodes.Status200OK,
                };
            }
            catch (Exception ex)
            {
                log.LogError(ex, UnhandledExceptionError);
                throw;
            }
        }

        /// <summary>
        /// Subscribes to the AudioCreated event.
        /// Transcribes the audio file using Congnitive Services Speech API.
        /// </summary>
        /// <param name="req">The request from the Event Grid to process event for a new audio file.</param>
        /// <param name="log">The logger to use to log information.</param>
        /// <returns>Returns an instance of the <see cref="OkResult"/> class if all is ok.
        /// If the audio file is not found it returns an instance of the <see cref="NotFoundResult"/> class.</returns>
        [FunctionName("UpdateAudioTranscript")]
        public static async Task<IActionResult> UpdateAudioTranscript(
            [HttpTrigger(AuthorizationLevel.Function, "post")]HttpRequest req,
            ILogger log)
        {
            if (req == null)
            {
                throw new ArgumentNullException(nameof(req));
            }

            // read the request stream
            if (req.Body.CanSeek)
            {
                req.Body.Position = 0;
            }

            using var streamReader = new StreamReader(req.Body);

            var requestBody = streamReader.ReadToEnd();

            req.Headers.TryGetValue(EventGridSubscriptionValidationHeaderKey, out StringValues headers);

            // authenticate to Event Grid if this is a validation event
            var eventGridValidationOutput = EventGridSubscriberService.HandleSubscriptionValidationEvent(requestBody, headers);
            if (eventGridValidationOutput != null)
            {
                log.LogInformation("Responding to Event Grid subscription verification.");
                return eventGridValidationOutput;
            }

            try
            {
                var (_, userId, audioId) = EventGridSubscriberService.DeconstructEventGridMessage(requestBody);

                // update the audio transcript
                var transcriptPreview = await AudioService.UpdateAudioTranscriptAsync(audioId, userId).ConfigureAwait(false);
                if (transcriptPreview == null)
                {
                    return new NotFoundResult();
                }

                return new OkResult();
            }
            catch (Exception ex)
            {
                log.LogError(ex, UnhandledExceptionError);
                throw;
            }
        }
    }
}
