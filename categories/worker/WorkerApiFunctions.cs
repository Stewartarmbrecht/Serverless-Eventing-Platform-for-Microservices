namespace ContentReactor.Categories.WorkerApi
{
    using System;
    using System.IO;
    using System.Threading.Tasks;
    using ContentReactor.Categories.Services;
    using ContentReactor.Common;
    using ContentReactor.Common.UserAuthentication;
    using Microsoft.AspNetCore.Http;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Azure.WebJobs;
    using Microsoft.Azure.WebJobs.Extensions.Http;
    using Microsoft.Extensions.Logging;
    using Microsoft.Extensions.Primitives;
    using Newtonsoft.Json;

    /// <summary>
    /// Work functions that process events that should trigger category updates.
    /// </summary>
    public class WorkerApiFunctions
    {
        private const string EventGridSubscriptionValidationHeaderKey = "Aeg-Event-Type";
        private const string JsonContentType = "application/json";

        /// <summary>
        /// Initializes a new instance of the <see cref="WorkerApiFunctions"/> class.
        /// </summary>
        /// <param name="categoriesService">The categories services to use.</param>
        /// <param name="userAuthentication">The user authentication service to use.</param>
        /// <param name="eventGridSubscriberService">The event grid subcriber service to use.</param>
        public WorkerApiFunctions(
            ICategoriesService categoriesService,
            IUserAuthenticationService userAuthentication,
            IEventGridSubscriberService eventGridSubscriberService)
        {
            this.CategoriesService = categoriesService;
            this.UserAuthenticationService = userAuthentication;
            this.EventGridSubscriberService = eventGridSubscriberService;
        }

        private ICategoriesService CategoriesService { get; }

        private IUserAuthenticationService UserAuthenticationService { get; }

        private IEventGridSubscriberService EventGridSubscriberService { get; }

        /// <summary>
        /// Performs a health check for the function.
        /// While empty now can be used to perform checks against
        /// predefined thresholds to help alert against cost overruns
        /// or certain types of client behavior that was blocked.
        /// </summary>
        /// <param name="req">The health check request.</param>
        /// <param name="log">The logger to use.</param>
        /// <returns>The health check status results. See <see cref="HealthCheckStatus"/> class.</returns>
        [FunctionName("HealthCheck")]
        public async Task<IActionResult> HealthCheck(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "healthcheck")]HttpRequest req,
            ILogger log)
        {
            if (req == null)
            {
                throw new ArgumentNullException(nameof(req));
            }

            // get the user ID
            if (!await this.UserAuthenticationService.GetUserIdAsync(req, out var userId, out var responseResult).ConfigureAwait(false))
            {
                return responseResult;
            }

            // list the categories
            try
            {
                var healthCheckResult = await this.CategoriesService.HealthCheckWorker(userId, req.Host.Host).ConfigureAwait(false);
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
                log.LogError(ex, "Unhandled exception");
                throw;
            }
        }

        /// <summary>
        /// Updates the synonyms for a category when a category is created or the name is updated.
        /// </summary>
        /// <param name="req">The event raised by the event grid request.</param>
        /// <param name="log">The logger to use.</param>
        /// <returns>OK results if successfull.</returns>
        [FunctionName("UpdateCategorySynonyms")]
        public async Task<IActionResult> UpdateCategorySynonyms(
            [HttpTrigger(AuthorizationLevel.Function, "post")]HttpRequest req,
            ILogger log)
        {
            if (req == null)
            {
                throw new ArgumentNullException(nameof(req));
            }

            (string requestBody, StringValues headers) = GetRequestBodyAndHeaders(req);

            // authenticate to Event Grid if this is a validation event
            var eventGridValidationOutput = this.EventGridSubscriberService.HandleSubscriptionValidationEvent(requestBody, headers);
            if (eventGridValidationOutput != null)
            {
                log.LogInformation("Responding to Event Grid subscription verification");
                return eventGridValidationOutput;
            }

            try
            {
                var (_, userId, categoryId) = this.EventGridSubscriberService.DeconstructEventGridMessage(requestBody);

                // process the category synonyms
                log.LogInformation($"Updating synonyms for category ID {categoryId}...");
                var updated = await this.CategoriesService.UpdateCategorySynonymsAsync(categoryId, userId).ConfigureAwait(false);
                if (!updated)
                {
                    log.LogWarning("Did not update category synonyms as no synonyms were available");
                }

                return new OkResult();
            }
            catch (Exception ex)
            {
                log.LogError(ex, "Unhandled exception");
                throw;
            }
        }

        /// <summary>
        /// Adds the preview of an item to a category when the item created event is raised.
        /// </summary>
        /// <param name="req">The event raised by the event grid request.</param>
        /// <param name="log">The logger to use.</param>
        /// <returns>OK results if successfull.</returns>
        [FunctionName("AddCategoryItem")]
        public async Task<IActionResult> AddCategoryItem(
            [HttpTrigger(AuthorizationLevel.Function, "post")]HttpRequest req,
            ILogger log)
        {
            if (req == null)
            {
                throw new ArgumentNullException(nameof(req));
            }

            (string requestBody, StringValues headers) = GetRequestBodyAndHeaders(req);

            // authenticate to Event Grid if this is a validation event
            var eventGridValidationOutput = this.EventGridSubscriberService.HandleSubscriptionValidationEvent(requestBody, headers);
            if (eventGridValidationOutput != null)
            {
                log.LogInformation("Responding to Event Grid subscription verification");
                return eventGridValidationOutput;
            }

            try
            {
                var (eventGridEvent, userId, _) = this.EventGridSubscriberService.DeconstructEventGridMessage(requestBody);

                // process the category item
                await this.CategoriesService.ProcessAddItemEventAsync(eventGridEvent, userId).ConfigureAwait(false);

                return new OkResult();
            }
            catch (Exception ex)
            {
                log.LogError(ex, "Unhandled exception");
                throw;
            }
        }

        /// <summary>
        /// Updates the preview of an item for a category when the item updated event is raised.
        /// </summary>
        /// <param name="req">The event raised by the event grid request.</param>
        /// <param name="log">The logger to use.</param>
        /// <returns>OK results if successfull.</returns>
        [FunctionName("UpdateCategoryItem")]
        public async Task<IActionResult> UpdateCategoryItem(
            [HttpTrigger(AuthorizationLevel.Function, "post")]HttpRequest req,
            ILogger log)
        {
            if (req == null)
            {
                throw new ArgumentNullException(nameof(req));
            }

            (string requestBody, StringValues headers) = GetRequestBodyAndHeaders(req);

            // authenticate to Event Grid if this is a validation event
            var eventGridValidationOutput = this.EventGridSubscriberService.HandleSubscriptionValidationEvent(requestBody, headers);
            if (eventGridValidationOutput != null)
            {
                log.LogInformation("Responding to Event Grid subscription verification");
                return eventGridValidationOutput;
            }

            try
            {
                var (eventGridEvent, userId, _) = this.EventGridSubscriberService.DeconstructEventGridMessage(requestBody);

                // process the category item
                await this.CategoriesService.ProcessUpdateItemEventAsync(eventGridEvent, userId).ConfigureAwait(false);

                return new OkResult();
            }
            catch (Exception ex)
            {
                log.LogError(ex, "Unhandled exception");
                throw;
            }
        }

        /// <summary>
        /// Removes an item from a category when the item deleted event is raised.
        /// </summary>
        /// <param name="req">The event raised by the event grid request.</param>
        /// <param name="log">The logger to use.</param>
        /// <returns>OK results if successfull.</returns>
        [FunctionName("DeleteCategoryItem")]
        public async Task<IActionResult> DeleteCategoryItem(
            [HttpTrigger(AuthorizationLevel.Function, "post")]HttpRequest req,
            ILogger log)
        {
            if (req == null)
            {
                throw new ArgumentNullException(nameof(req));
            }

            (string requestBody, StringValues headers) = GetRequestBodyAndHeaders(req);

            // authenticate to Event Grid if this is a validation event
            var eventGridValidationOutput = this.EventGridSubscriberService.HandleSubscriptionValidationEvent(requestBody, headers);
            if (eventGridValidationOutput != null)
            {
                log.LogInformation("Responding to Event Grid subscription verification");
                return eventGridValidationOutput;
            }

            try
            {
                var (eventGridEvent, userId, _) = this.EventGridSubscriberService.DeconstructEventGridMessage(requestBody);

                // process the category item
                await this.CategoriesService.ProcessDeleteItemEventAsync(eventGridEvent, userId).ConfigureAwait(false);

                return new OkResult();
            }
            catch (Exception ex)
            {
                log.LogError(ex, "Unhandled exception");
                throw;
            }
        }

        /// <summary>
        /// Updates the image for category when the created or name updated event is raised.
        /// </summary>
        /// <param name="req">The event raised by the event grid request.</param>
        /// <param name="log">The logger to use.</param>
        /// <returns>OK results if successfull.</returns>
        [FunctionName("AddCategoryImage")]
        public async Task<IActionResult> AddCategoryImage(
            [HttpTrigger(AuthorizationLevel.Function, "post")]HttpRequest req,
            ILogger log)
        {
            if (req == null)
            {
                throw new ArgumentNullException(nameof(req));
            }

            (string requestBody, StringValues headers) = GetRequestBodyAndHeaders(req);

            // authenticate to Event Grid if this is a validation event
            var eventGridValidationOutput = this.EventGridSubscriberService.HandleSubscriptionValidationEvent(requestBody, headers);
            if (eventGridValidationOutput != null)
            {
                log.LogInformation("Responding to Event Grid subscription verification");
                return eventGridValidationOutput;
            }

            try
            {
                var (_, userId, categoryId) = this.EventGridSubscriberService.DeconstructEventGridMessage(requestBody);

                // process the category image
                log.LogInformation($"Updating image for category ID {categoryId}...");
                var updated = await this.CategoriesService.UpdateCategoryImageAsync(categoryId, userId).ConfigureAwait(false);
                if (!updated)
                {
                    log.LogWarning("Did not update category image as no images were available");
                }

                return new OkResult();
            }
            catch (Exception ex)
            {
                log.LogError(ex, "Unhandled exception");
                throw;
            }
        }

        private static (string requestBody, StringValues headers) GetRequestBodyAndHeaders(HttpRequest req)
        {
            // read the request stream
            if (req.Body.CanSeek)
            {
                req.Body.Position = 0;
            }

            using var streamReader = new StreamReader(req.Body);

            var requestBody = streamReader.ReadToEnd();

            req.Headers.TryGetValue(EventGridSubscriptionValidationHeaderKey, out StringValues headers);

            return (requestBody, headers);
        }
    }
}
