namespace ContentReactor.Audio.Api
{
    using System;
    using System.IO;
    using System.Threading.Tasks;
    using ContentReactor.Audio.Services;
    using ContentReactor.Audio.Services.Converters;
    using ContentReactor.Audio.Services.Models.Requests;
    using ContentReactor.Audio.Services.Models.Results;
    using ContentReactor.Common;
    using ContentReactor.Common.Blobs;
    using ContentReactor.Common.UserAuthentication;
    using Microsoft.AspNetCore.Http;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Azure.WebJobs;
    using Microsoft.Azure.WebJobs.Extensions.Http;
    using Microsoft.Extensions.Logging;
    using Newtonsoft.Json;

    /// <summary>
    /// Functions for Audio API.
    /// </summary>
    public static class ApiFunctions
    {
        private const string JsonContentType = "application/json";
        private const string UnhandledExceptionError = "Unhandled Exception.";

        /// <summary>
        /// Service for audio files.
        /// </summary>
        private static readonly IAudioService AudioService = new AudioService(new BlobRepository(), new AudioTranscriptionService(), new EventGridPublisherService());

        /// <summary>
        /// Authentication Service.
        /// </summary>
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
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "healthcheck")] HttpRequest req,
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
                var healthCheckResult = await AudioService.HealthCheckApi(userId, req.Host.Host).ConfigureAwait(false);
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
        /// Creates a placeholder blob and returns the id and URL to upload the actual audio file.
        /// </summary>
        /// <param name="req">The http request to create the audio blob.</param>
        /// <param name="log">The logger to use for logging.</param>
        /// <returns>Id of the new blog and URL to pose the blob to.</returns>
        [FunctionName("BeginCreateAudio")]
        public static async Task<IActionResult> BeginCreateAudio(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "audio")]HttpRequest req,
            ILogger log)
        {
            // get the user ID
            if (!await UserAuthenticationService.GetUserIdAsync(req, out var userId, out var responseResult).ConfigureAwait(false))
            {
                return responseResult;
            }

            // create the audio note
            try
            {
                var (id, url) = await AudioService.BeginAddAudioNote(userId).ConfigureAwait(false);
                return new OkObjectResult(new
                {
                    id,
                    url,
                });
            }
            catch (Exception ex)
            {
                log.LogError(ex, UnhandledExceptionError);
                throw;
            }
        }

        /// <summary>
        /// Called after the blob has been uploaded to the container.
        /// </summary>
        /// <param name="req">The http request to complete the audio blob after uploading it to storage.</param>
        /// <param name="log">The logger to use for logging.</param>
        /// <param name="id">The id of the blob to complete.</param>
        /// <returns>Empty success result.</returns>
        [FunctionName("CompleteCreateAudio")]
        public static async Task<IActionResult> CompleteCreateAudio(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "audio/{id}")]HttpRequest req,
            ILogger log,
            string id)
        {
            if (req == null)
            {
                throw new ArgumentNullException(nameof(req));
            }

            // get request body
            var requestBody = await new StreamReader(req.Body).ReadToEndAsync().ConfigureAwait(false);
            CompleteCreateAudioRequest data;
            try
            {
                data = JsonConvert.DeserializeObject<CompleteCreateAudioRequest>(requestBody);
            }
            catch (JsonReaderException)
            {
                return new BadRequestObjectResult(new { error = "Body should be provided in JSON format." });
            }

            // validate the request body
            if (data == null || string.IsNullOrEmpty(data.CategoryId))
            {
                return new BadRequestObjectResult(new { error = "Missing required property 'categoryId'." });
            }

            // get the user ID
            if (!await UserAuthenticationService.GetUserIdAsync(req, out var userId, out var responseResult).ConfigureAwait(false))
            {
                return responseResult;
            }

            // finish creating the audio note
            try
            {
                var result = await AudioService.CompleteAddAudioNoteAsync(id, userId, data.CategoryId).ConfigureAwait(false);

                return result switch
                {
                    CompleteAddAudioNoteResult.Success => new NoContentResult(),
                    CompleteAddAudioNoteResult.AudioNotUploaded => new BadRequestObjectResult(new { error = "Audio has not yet been uploaded." }),
                    CompleteAddAudioNoteResult.AudioAlreadyCreated => new BadRequestObjectResult(new { error = "Image has already been created." }),
                    _ => throw new InvalidOperationException($"Unexpected result '{result}' from {nameof(AudioService)}.{nameof(AudioService.CompleteAddAudioNoteAsync)}"),
                };
            }
            catch (Exception ex)
            {
                log.LogError(ex, UnhandledExceptionError);
                throw;
            }
        }

        /// <summary>
        /// Gets metadata and URL to download audio file.
        /// </summary>
        /// <param name="req">The request.</param>
        /// <param name="log">Logger used for logging.</param>
        /// <param name="id">The id of the audio file to get the data for.</param>
        /// <returns>Metadata about the audio file and the URL to download.</returns>
        [FunctionName("GetAudio")]
        public static async Task<IActionResult> GetAudio(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "audio/{id}")]HttpRequest req,
            ILogger log,
            string id)
        {
            // get the user ID
            if (!await UserAuthenticationService.GetUserIdAsync(req, out var userId, out var responseResult).ConfigureAwait(false))
            {
                return responseResult;
            }

            // get the audio note
            try
            {
                var audioNoteDetails = await AudioService.GetAudioNoteAsync(id, userId).ConfigureAwait(false);
                if (audioNoteDetails == null)
                {
                    return new NotFoundResult();
                }

                return new OkObjectResult(audioNoteDetails);
            }
            catch (Exception ex)
            {
                log.LogError(ex, UnhandledExceptionError);
                throw;
            }
        }

        /// <summary>
        /// Gets a list of audio notes for a user.
        /// </summary>
        /// <param name="req">The request.</param>
        /// <param name="log">Logger used for logging.</param>
        /// <returns>Collection of audio note summarites. An instance of the <see cref="Services.Models.Responses.AudioNoteSummaryCollection"/> class.</returns>
        [FunctionName("ListAudio")]
        public static async Task<IActionResult> ListAudio(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "audio")]HttpRequest req,
            ILogger log)
        {
            // get the user ID
            if (!await UserAuthenticationService.GetUserIdAsync(req, out var userId, out var responseResult).ConfigureAwait(false))
            {
                return responseResult;
            }

            // lilst the audio notes
            try
            {
                var summaries = await AudioService.ListAudioNotesAsync(userId).ConfigureAwait(false);
                if (summaries == null)
                {
                    return new NotFoundResult();
                }

                // serialise the summaries using a custom converter
                // var settings = new JsonSerializerSettings
                // {
                //     NullValueHandling = NullValueHandling.Ignore,
                //     Formatting = Formatting.Indented,
                // };
                // settings.Converters.Add(new AudioNoteSummariesConverter());

                // var json = JsonConvert.SerializeObject(summaries, settings);
                var json = JsonConvert.SerializeObject(summaries);

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
        /// Deletes an audio note from the repository.
        /// </summary>
        /// <param name="req">The request.</param>
        /// <param name="log">Logger used for logging.</param>
        /// <param name="id">The id of the audio file to delete.</param>
        /// <returns>Collection of audio note summarites. An instance of the <see cref="Services.Models.Responses.AudioNoteSummaryCollection"/> class.</returns>
        [FunctionName("DeleteAudio")]
        public static async Task<IActionResult> DeleteAudio(
            [HttpTrigger(AuthorizationLevel.Anonymous, "delete", Route = "audio/{id}")]HttpRequest req,
            ILogger log,
            string id)
        {
            // get the user ID
            if (!await UserAuthenticationService.GetUserIdAsync(req, out var userId, out var responseResult).ConfigureAwait(false))
            {
                return responseResult;
            }

            // delete the audio note
            try
            {
                await AudioService.DeleteAudioNoteAsync(id, userId).ConfigureAwait(false);
                return new NoContentResult();
            }
            catch (Exception ex)
            {
                log.LogError(ex, UnhandledExceptionError);
                throw;
            }
        }
    }
}
