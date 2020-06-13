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
        /// Gets metadata and URL to download audio file.
        /// </summary>
        /// <param name="req">The request.</param>
        /// <param name="log">Logger used for logging.</param>
        /// <param name="id">The id of the audio file to get the data for.</param>
        /// <returns>Metadata about the audio file and the URL to download.</returns>
        [FunctionName("GetAudio")]
        public async Task<IActionResult> Get(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "audio/{id}")]HttpRequest req,
            ILogger log,
            string id)
        {
            // get the audio note
            try
            {
                // get the user ID
                if (!await this.UserAuthenticationService.GetUserIdAsync(req, out var userId, out var responseResult).ConfigureAwait(false))
                {
                    return responseResult;
                }

                var audioBlob = await this.BlobRepository.GetBlobAsync(AudioBlobContainerName, $"{userId}/{id}").ConfigureAwait(false);
                if (audioBlob == null)
                {
                    return new NotFoundResult();
                }

                Uri blobDownloadUrl = this.BlobRepository.GetBlobDownloadUrl(audioBlob);

                var response = new GetResponse
                {
                    Id = id,
                    AudioUrl = blobDownloadUrl,
                    Transcript = audioBlob.Properties.ContainsKey(TranscriptMetadataName) ? audioBlob.Properties[TranscriptMetadataName] : null,
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
