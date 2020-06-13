namespace ContentReactor.Audio.Service
{
    using System;
    using System.IO;
    using System.Threading.Tasks;
    using ContentReactor.Common.Blobs;
    using ContentReactor.Common.Events;
    using ContentReactor.Common.Events.Audio;
    using ContentReactor.Common.UserAuthentication;
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
        /// Called after the blob has been uploaded to the container.
        /// </summary>
        /// <param name="req">The http request to complete the audio blob after uploading it to storage.</param>
        /// <param name="log">The logger to use for logging.</param>
        /// <param name="id">The id of the blob to complete.</param>
        /// <returns>Empty success result.</returns>
        [FunctionName("AudioAddComplete")]
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1062", Justification = "Reviewed")]
        public async Task<IActionResult> AddComplete(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "audio/{id}")]HttpRequest req,
            ILogger log,
            string id)
        {
            // finish creating the audio note
            try
            {
                // get the user ID
                if (!await this.UserAuthenticationService.GetUserIdAsync(req, out var userId, out var responseResult).ConfigureAwait(false))
                {
                    return responseResult;
                }

                // get request body
                using var streamReader = new StreamReader(req.Body);
                var requestBody = await streamReader.ReadToEndAsync().ConfigureAwait(false);
                AddCompleteRequest payload;
                try
                {
                    payload = JsonConvert.DeserializeObject<AddCompleteRequest>(requestBody);
                }
                catch (JsonReaderException)
                {
                    return new BadRequestObjectResult(new { error = "Body should be provided in JSON format." });
                }

                // validate the request body
                if (payload == null || string.IsNullOrEmpty(payload.CategoryId))
                {
                    return new BadRequestObjectResult(new { error = "Missing required property 'categoryId'." });
                }

                var blob = await this.BlobRepository.GetBlobAsync(AudioBlobContainerName, $"{userId}/{id}").ConfigureAwait(false);
                if (blob == null)
                {
                    // the blob hasn't actually been uploaded yet, so we can't process it
                    return new BadRequestObjectResult(new { error = "Audio has not yet been uploaded." });
                }

                // if the blob already contains metadata then that means it has already been added
                if (blob.Properties.ContainsKey(CategoryIdMetadataName))
                {
                    return new BadRequestObjectResult(new { error = "Image has already been created." });
                }

                // set the blob metadata
                blob.Properties.Add(CategoryIdMetadataName, payload.CategoryId);
                blob.Properties.Add(UserIdMetadataName, userId);
                await this.BlobRepository.UpdateBlobPropertiesAsync(blob).ConfigureAwait(false);

                // publish an event into the Event Grid topic
                var subject = $"{userId}/{id}";
                await this.EventGridPublisherService.PostEventGridEventAsync(
                    AudioEvents.AudioCreated,
                    subject,
                    new AudioCreatedEventData { Category = payload.CategoryId }).ConfigureAwait(false);

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
