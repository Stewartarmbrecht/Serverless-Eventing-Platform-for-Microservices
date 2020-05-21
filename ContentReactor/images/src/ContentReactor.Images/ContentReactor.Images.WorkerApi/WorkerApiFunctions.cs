using System;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.Http;
using ContentReactor.Images.Services;
using ContentReactor.Images.Services.Models.Results;
using ContentReactor.Common;
using ContentReactor.Common.BlobRepository;
using ContentReactor.Common.UserAuthentication;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Azure.WebJobs.Host;
using Newtonsoft.Json;

namespace ContentReactor.Images.WorkerApi
{
    public static class WorkerApiFunctions
    {
        private const string JsonContentType = "application/json";
        private static readonly IEventGridSubscriberService EventGridSubscriberService = new EventGridSubscriberService();
        private static readonly IImagesService ImagesService = new ImagesService(new BlobRepository(), new ImageValidatorService(),  new ImagePreviewService(), new ImageCaptionService(new HttpClient()), new EventGridPublisherService());
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
                var healthCheckResult = await ImagesService.HealthCheckWorker(userId, req.Host.Host);
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

        [FunctionName("UpdateImageCaption")]
        public static async Task<IActionResult> UpdateImageCaption(
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
                var (_, userId, imageId) = EventGridSubscriberService.DeconstructEventGridMessage(req);

                // process the image caption
                var result = await ImagesService.UpdateImageNoteCaptionAsync(imageId, userId);
                switch (result)
                {
                    case UpdateImageNoteCaptionResult.Success:
                        return new OkResult();
                    case UpdateImageNoteCaptionResult.NotFound:
                        return new NotFoundResult();
                    default:
                        throw new InvalidOperationException($"{nameof(ImagesService.UpdateImageNoteCaptionAsync)} returned unexpected result {result}.");
                }
            }
            catch (Exception ex)
            {
                log.Error("Unhandled exception", ex);
                return new ExceptionResult(ex, false);
            }
        }
    }
}
