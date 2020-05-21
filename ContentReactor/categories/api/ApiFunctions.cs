namespace ContentReactor.Categories.Api
{
    using System;
    using System.IO;
    using System.Threading.Tasks;
    using ContentReactor.Categories.Services;
    using ContentReactor.Categories.Services.Converters;
    using ContentReactor.Categories.Services.Models.Request;
    using ContentReactor.Categories.Services.Models.Results;
    using ContentReactor.Common;
    using ContentReactor.Common.UserAuthentication;
    using Microsoft.AspNetCore.Http;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Azure.WebJobs;
    using Microsoft.Azure.WebJobs.Extensions.Http;
    using Microsoft.Extensions.Localization;
    using Microsoft.Extensions.Logging;
    using Newtonsoft.Json;

    /// <summary>
    /// API for managing categories.
    /// </summary>
    public class ApiFunctions
    {
        private const string JsonContentType = "application/json";

        /// <summary>
        /// Initializes a new instance of the <see cref="ApiFunctions"/> class.
        /// </summary>
        /// <param name="categoriesService">The categories services to use.</param>
        /// <param name="userAuthentication">The user authentication service to use.</param>
        public ApiFunctions(
            ICategoriesService categoriesService,
            IUserAuthenticationService userAuthentication)
        {
            this.CategoriesService = categoriesService;
            this.UserAuthenticationService = userAuthentication;
        }

        private ICategoriesService CategoriesService { get; }

        private IUserAuthenticationService UserAuthenticationService { get; }

        private IStringLocalizer StringLocalizer { get; }

        /// <summary>
        /// Performs a health check for the function.
        /// While empty now can be used to perform checks against
        /// predefined thresholds to help alert against cost overruns
        /// or certain types of client behavior that was blocked.
        /// </summary>
        /// <param name="req">The request for the health check.</param>
        /// <param name="log">The logger to use.</param>
        /// <returns>The results of the health check. An instance of the <see cref="HealthCheckResults"/> class.</returns>
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
                var healthCheckResult = await this.CategoriesService.HealthCheckApi(userId, req.Host.Host).ConfigureAwait(false);
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
        /// Creates a new category.
        /// </summary>
        /// <param name="req">The request to add the new category.</param>
        /// <param name="log">The logger to use for logging.</param>
        /// <returns>Object with the id of the new category.</returns>
        [FunctionName("AddCategory")]
        public async Task<IActionResult> AddCategory(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "categories")]HttpRequest req,
            ILogger log)
        {
            if (req == null)
            {
                throw new ArgumentNullException(nameof(req));
            }

            // get the request body
            using var bodyReader = new StreamReader(req.Body);
            var requestBody = await bodyReader.ReadToEndAsync().ConfigureAwait(false);
            CreateCategoryRequest data;
            try
            {
                data = JsonConvert.DeserializeObject<CreateCategoryRequest>(requestBody);
            }
            catch (JsonReaderException)
            {
                return new BadRequestObjectResult(new { error = "Body should be provided in JSON format." });
            }

            // validate request
            if (data == null || string.IsNullOrEmpty(data.Name))
            {
                return new BadRequestObjectResult(new { error = "Missing required property 'name'." });
            }

            // get the user ID
            if (!await this.UserAuthenticationService.GetUserIdAsync(req, out var userId, out var responseResult).ConfigureAwait(false))
            {
                return responseResult;
            }

            // create category
            try
            {
                var categoryId = await this.CategoriesService.AddCategoryAsync(data.Name, userId).ConfigureAwait(false);
                return new OkObjectResult(new { id = categoryId });
            }
            catch (Exception ex)
            {
                log.LogError(ex, "Unhandled exception");
                throw;
            }
        }

        /// <summary>
        /// Deletes a category.
        /// </summary>
        /// <param name="req">The request to add the new category.</param>
        /// <param name="log">The logger to use for logging.</param>
        /// <param name="id">The id of the category to delete.</param>
        /// <returns>Object with the id of the new category.</returns>
        [FunctionName("DeleteCategory")]
        public async Task<IActionResult> DeleteCategory(
            [HttpTrigger(AuthorizationLevel.Anonymous, "delete", Route = "categories/{id}")]HttpRequest req,
            ILogger log,
            string id)
        {
            if (req == null)
            {
                throw new ArgumentNullException(nameof(req));
            }

            // validate request
            if (string.IsNullOrEmpty(id))
            {
                return new BadRequestObjectResult(new { error = "Missing required argument 'id'." });
            }

            // get the user ID
            if (!await this.UserAuthenticationService.GetUserIdAsync(req, out var userId, out var responseResult).ConfigureAwait(false))
            {
                return responseResult;
            }

            // delete category
            try
            {
                await this.CategoriesService.DeleteCategoryAsync(id, userId).ConfigureAwait(false); // we ignore the result of this call - whether it's Success or NotFound, we return an 'Ok' back to the client
                return new NoContentResult();
            }
            catch (Exception ex)
            {
                log.LogError(ex, "Unhandled exception");
                throw;
            }
        }

        /// <summary>
        /// Updates the name of a category and raises events to process all additional updates
        /// on synonyms and images.
        /// </summary>
        /// <param name="req">The request to add the new category.</param>
        /// <param name="log">The logger to use for logging.</param>
        /// <param name="id">The id of the category to update.</param>
        /// <returns>Returns <see cref="NoContentResult"/> if sucessful.</returns>
        [FunctionName("UpdateCategory")]
        public async Task<IActionResult> UpdateCategory(
            [HttpTrigger(AuthorizationLevel.Anonymous, "patch", Route = "categories/{id}")]HttpRequest req,
            ILogger log,
            string id)
        {
            if (req == null)
            {
                throw new ArgumentNullException(nameof(req));
            }

            // get the request body
            using var bodyReader = new StreamReader(req.Body);
            var requestBody = await bodyReader.ReadToEndAsync().ConfigureAwait(false);
            UpdateCategoryRequest data;
            try
            {
                data = JsonConvert.DeserializeObject<UpdateCategoryRequest>(requestBody);
            }
            catch (JsonReaderException)
            {
                return new BadRequestObjectResult(new { error = "Body should be provided in JSON format." });
            }

            // validate request
            if (data == null)
            {
                return new BadRequestObjectResult(new { error = "Missing required property 'name'." });
            }

            if (data.Id != null && id != null && data.Id != id)
            {
                return new BadRequestObjectResult(new { error = "Property 'id' does not match the identifier specified in the URL path." });
            }

            if (string.IsNullOrEmpty(data.Id))
            {
                data.Id = id;
            }

            if (string.IsNullOrEmpty(data.Name))
            {
                return new BadRequestObjectResult(new { error = "Missing required property 'name'." });
            }

            // get the user ID
            if (!await this.UserAuthenticationService.GetUserIdAsync(req, out var userId, out var responseResult).ConfigureAwait(false))
            {
                return responseResult;
            }

            // update category name
            try
            {
                var result = await this.CategoriesService.UpdateCategoryAsync(data.Id, userId, data.Name).ConfigureAwait(false);
                if (result == UpdateCategoryResult.NotFound)
                {
                    return new NotFoundResult();
                }

                return new NoContentResult();
            }
            catch (Exception ex)
            {
                log.LogError(ex, "Unhandled exception");
                throw;
            }
        }

        /// <summary>
        /// Gets the full details of a category.
        /// </summary>
        /// <param name="req">The request to add the new category.</param>
        /// <param name="log">The logger to use for logging.</param>
        /// <param name="id">The id of the category to get.</param>
        /// <returns>An instance of the <see cref="ContentReactor.Categories.Services.Models.Response.CategoryDetails"/> if found.</returns>
        [FunctionName("GetCategory")]
        public async Task<IActionResult> GetCategory(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "categories/{id}")]HttpRequest req,
            ILogger log,
            string id)
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

            // get the category details
            try
            {
                var document = await this.CategoriesService.GetCategoryAsync(id, userId).ConfigureAwait(false);
                if (document == null)
                {
                    return new NotFoundResult();
                }

                return new OkObjectResult(document);
            }
            catch (Exception ex)
            {
                log.LogError(ex, "Unhandled exception");
                throw;
            }
        }

        /// <summary>
        /// Gets a list of categories for a single user.
        /// </summary>
        /// <param name="req">The request to add the new category.</param>
        /// <param name="log">The logger to use for logging.</param>
        /// <returns>An instance of the <see cref="ContentReactor.Categories.Services.Models.Response.CategoryDetails"/> if found.</returns>
        [FunctionName("ListCategories")]
        public async Task<IActionResult> ListCategories(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "categories")]HttpRequest req,
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
                var summaries = await this.CategoriesService.ListCategoriesAsync(userId).ConfigureAwait(false);
                if (summaries == null)
                {
                    return new NotFoundResult();
                }

                // serialise the summaries using a custom converter
                var settings = new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore,
                    Formatting = Formatting.Indented,
                };
                settings.Converters.Add(new CategorySummariesConverter());
                var json = JsonConvert.SerializeObject(summaries, settings);

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
    }
}
