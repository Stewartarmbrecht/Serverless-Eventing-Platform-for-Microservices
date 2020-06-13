namespace ContentReactor.Audio.Service
{
    using System;
    using System.Linq;
    using System.Threading.Tasks;
    using ContentReactor.Audio.Service;
    using ContentReactor.Common;
    using ContentReactor.Common.Blobs;
    using ContentReactor.Common.Events;
    using ContentReactor.Common.UserAuthentication;
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
        /// Gets a list of audio notes for a user.
        /// </summary>
        /// <param name="req">The request.</param>
        /// <param name="log">Logger used for logging.</param>
        /// <returns>Collection of audio note summarites. An instance of the <see cref="GetListItem"/> class.</returns>
        [FunctionName("ListAudio")]
        public async Task<IActionResult> GetList(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "audio")]HttpRequest req,
            ILogger log)
        {
            try
            {
                // get the user ID
                if (!await this.UserAuthenticationService.GetUserIdAsync(req, out var userId, out var responseResult).ConfigureAwait(false))
                {
                    return responseResult;
                }

                // list the audio notes
                var blobs = await this.BlobRepository.ListBlobsInFolderAsync(AudioBlobContainerName, userId).ConfigureAwait(false);
                var blobSummaries = blobs
                    .Select(b => new GetListItem
                    {
                        Id = b.BlobName.Split('/')[1],
                        Preview = b.Properties.ContainsKey(TranscriptMetadataName) ? b.Properties[TranscriptMetadataName].Truncate(TranscriptPreviewLength) : string.Empty,
                    })
                    .ToList();

                var audioNoteSummaries = new GetListResponse();
                audioNoteSummaries.AddRange(blobSummaries);

                return new ObjectResult(audioNoteSummaries);
            }
            catch (Exception ex)
            {
                log.LogError(ex, UnhandledExceptionError);
                throw;
            }
        }
    }
}
