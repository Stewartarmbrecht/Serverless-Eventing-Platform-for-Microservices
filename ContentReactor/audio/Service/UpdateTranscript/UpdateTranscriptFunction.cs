namespace ContentReactor.Audio.Service
{
    using System;
    using System.IO;
    using System.Threading.Tasks;
    using ContentReactor.Common;
    using ContentReactor.Common.Events.Audio;
    using Microsoft.AspNetCore.Http;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Azure.WebJobs;
    using Microsoft.Azure.WebJobs.Extensions.Http;
    using Microsoft.Extensions.Logging;
    using Microsoft.Extensions.Primitives;

    /// <summary>
    /// Service that processes audio events.
    /// Provides API called by the event grid to process events audio events.
    /// </summary>
    public partial class Functions
    {
        /// <summary>
        /// The name of the header key that signifies the request is a
        /// validation request and not an actual request for the function
        /// to execute.
        /// </summary>
        private const string EventGridSubscriptionValidationHeaderKey = "Aeg-Event-Type";

        /// <summary>
        /// Subscribes to the AudioCreated event.
        /// Transcribes the audio file using Congnitive Services Speech API.
        /// </summary>
        /// <param name="req">The request from the Event Grid to process event for a new audio file.</param>
        /// <param name="log">The logger to use to log information.</param>
        /// <returns>Returns an instance of the <see cref="OkResult"/> class if all is ok.
        /// If the audio file is not found it returns an instance of the <see cref="NotFoundResult"/> class.</returns>
        [FunctionName("UpdateAudioTranscript")]
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1062", Justification = "Reviewed")]
        public async Task<IActionResult> UpdateTranscript(
            [HttpTrigger(AuthorizationLevel.Function, "post")]HttpRequest req,
            ILogger log)
        {
            try
            {
                // read the request stream
                if (req.Body.CanSeek)
                {
                    req.Body.Position = 0;
                }

                using var streamReader = new StreamReader(req.Body);

                var requestBody = streamReader.ReadToEnd();

                req.Headers.TryGetValue(EventGridSubscriptionValidationHeaderKey, out StringValues headers);

                // authenticate to Event Grid if this is a validation event
                var eventGridValidationOutput = this.EventGridSubscriberService.HandleSubscriptionValidationEvent(requestBody, headers);
                if (eventGridValidationOutput != null)
                {
                    log.LogInformation("Responding to Event Grid subscription verification.");
                    return eventGridValidationOutput;
                }

                var eventGridRequest = this.EventGridSubscriberService.DeconstructEventGridMessage<AudioCreatedEventData>(requestBody);
                var subject = $"{eventGridRequest.UserId}/{eventGridRequest.ItemId}";

                // update the audio transcript
                // get the blob
                var audioBlob = await this.BlobRepository.GetBlobAsync(
                    AudioBlobContainerName,
                    subject).ConfigureAwait(false);
                if (audioBlob == null)
                {
                    return new NotFoundResult();
                }

                // Get download url for the blob.
                using MemoryStream blobStream = new MemoryStream();
                await this.BlobRepository.CopyBlobToStreamAsync(
                    AudioBlobContainerName,
                    subject,
                    blobStream).ConfigureAwait(false);

                // send to Cognitive Services and get back a transcript
                string transcript = await this.AudioTranscriptionService.GetAudioTranscriptFromCognitiveServicesAsync(blobStream).ConfigureAwait(false);

                if (transcript == null)
                {
                    return new NotFoundResult();
                }

                // update the blob's metadata
                audioBlob.Properties[TranscriptMetadataName] = transcript;
                await this.BlobRepository.UpdateBlobPropertiesAsync(audioBlob).ConfigureAwait(false);

                // create a preview form of the transcript
                var transcriptPreview = transcript.Truncate(TranscriptPreviewLength);

                // fire an event into the Event Grid topic
                await this.EventGridPublisherService.PostEventGridEventAsync(
                    AudioEvents.AudioTranscriptUpdated,
                    subject,
                    new AudioTranscriptUpdatedEventData { TranscriptPreview = transcriptPreview }).ConfigureAwait(false);

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
