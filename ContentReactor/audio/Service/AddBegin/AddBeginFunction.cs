namespace ContentReactor.Audio.Service
{
    using System;
    using System.Threading.Tasks;
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
        /// Creates a placeholder blob and returns the id and URL to upload the actual audio file.
        /// </summary>
        /// <param name="req">The http request to create the audio blob.</param>
        /// <param name="log">The logger to use for logging.</param>
        /// <returns>Id of the new blog and URL to pose the blob to.</returns>
        [FunctionName("AudioAddBegin")]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<IActionResult> AddBegin(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "audio")]HttpRequest req,
            ILogger log)
        {
            // create the audio note
            try
            {
                // get the user ID
                if (!await this.UserAuthenticationService.GetUserIdAsync(req, out var userId, out var responseResult).ConfigureAwait(false))
                {
                    return responseResult;
                }

                // generate an ID for this audio note
                var audioId = Guid.NewGuid().ToString();

                // create a blob placeholder (which will not have any content yet)
                var blobUri = await this.BlobRepository.GetBlobUploadUrlAsync(AudioBlobContainerName, $"{userId}/{audioId}").ConfigureAwait(false);
                var response = new AddBeginResponse()
                {
                    Id = audioId,
                    UploadUrl = blobUri,
                };
                return new OkObjectResult(response);
            }
            catch (Exception ex)
            {
                log.LogError(ex, UnhandledExceptionError);
                throw;
            }
        }
    }
}
