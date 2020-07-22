namespace ContentReactor.Audio.Service
{
    using System;
    using System.Threading.Tasks;
    using ContentReactor.Common.Events.Audio;
    using Microsoft.AspNetCore.Http;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Azure.WebJobs;
    using Microsoft.Azure.WebJobs.Extensions.Http;
    using Microsoft.Extensions.Logging;

    /// <summary>
    /// Contains the operation for beginning the add of an audio file.
    /// </summary>
    public partial class Functions
    {
        /// <summary>
        /// Deletes an audio note from the repository.
        /// </summary>
        /// <param name="req">The request.</param>
        /// <param name="log">Logger used for logging.</param>
        /// <param name="id">The id of the audio file to delete.</param>
        /// <returns>No content result if successful.</returns>
        [FunctionName("DeleteAudio")]
        public async Task<IActionResult> Delete(
            [HttpTrigger(AuthorizationLevel.Anonymous, "delete", Route = "audio/{id}")]HttpRequest req,
            ILogger log,
            string id)
        {
            // delete the audio note
            try
            {
                // get the user ID
                if (!await this.UserAuthenticationService.GetUserIdAsync(req, out var userId, out var responseResult).ConfigureAwait(false))
                {
                    return responseResult;
                }

                // delete the blog
                await this.BlobRepository.DeleteBlobAsync(AudioBlobContainerName, $"{userId}/{id}").ConfigureAwait(false);

                // fire an event into the Event Grid topic
                var subject = $"{userId}/{id}";
                await this.EventGridPublisherService.PostEventGridEventAsync(AudioEvents.AudioDeleted, subject, new AudioDeletedEventData()).ConfigureAwait(false);
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
