namespace ContentReactor.Audio.Services
{
    using System;
    using System.IO;
    using System.Linq;
    using System.Threading.Tasks;
    using ContentReactor.Audio.Services.Models.Responses;
    using ContentReactor.Audio.Services.Models.Results;
    using ContentReactor.Common;
    using ContentReactor.Common.Blobs;
    using ContentReactor.Common.EventSchemas.Audio;
    using ContentReactor.Common.EventTypes;

    /// <summary>
    /// Provides operations for managing audio files.
    /// </summary>
    public class AudioService : IAudioService
    {
        /// <summary>
        /// Name of the audio blob container.
        /// </summary>
        protected internal const string AudioBlobContainerName = "audio";

        /// <summary>
        /// Name of meta data field that holds the transcript.
        /// </summary>
        protected internal const string TranscriptMetadataName = "transcript";

        /// <summary>
        /// Id of the category the audio file is organized under.
        /// </summary>
        protected internal const string CategoryIdMetadataName = "categoryId";

        /// <summary>
        /// Name of the metadata field that holds the user id.
        /// </summary>
        protected internal const string UserIdMetadataName = "userId";

        /// <summary>
        /// Length of the transcript preview.
        /// </summary>
        protected internal const int TranscriptPreviewLength = 100;

        private readonly IBlobRepository blobRepository;
        private readonly IAudioTranscriptionService audioTranscriptionService;
        private readonly IEventGridPublisherService eventGridPublisherService;

        /// <summary>
        /// Initializes a new instance of the <see cref="AudioService"/> class.
        /// </summary>
        /// <param name="blobRepository">The interface to use to interact with the blob repository.</param>
        /// <param name="audioTranscriptionService">The service to use for transcribing the audio files.</param>
        /// <param name="eventGridPublisherService">The service to use for publishing the events.</param>
        public AudioService(IBlobRepository blobRepository, IAudioTranscriptionService audioTranscriptionService, IEventGridPublisherService eventGridPublisherService)
        {
            this.blobRepository = blobRepository;
            this.audioTranscriptionService = audioTranscriptionService;
            this.eventGridPublisherService = eventGridPublisherService;
        }

        /// <summary>
        /// Performas a health check of all depdendencies of the API service.
        /// </summary>
        /// <param name="userId">Id of the user performing the health check.</param>
        /// <param name="app">Name of the hosting environment.</param>
        /// <returns>The results of the health check.</returns>
        public Task<HealthCheckResults> HealthCheckApi(string userId, string app)
        {
            var healthCheckResults = new HealthCheckResults()
            {
                Status = HealthCheckStatus.OK,
                Application = app,
            };
            return Task.FromResult<HealthCheckResults>(healthCheckResults);
        }

        /// <summary>
        /// Performas a health check of all depdendencies of the worker service.
        /// </summary>
        /// <param name="userId">Id of the user performing the health check.</param>
        /// <param name="app">Name of the hosting environment.</param>
        /// <returns>The results of the health check.</returns>
        public Task<HealthCheckResults> HealthCheckWorker(string userId, string app)
        {
            var healthCheckResults = new HealthCheckResults()
            {
                Status = HealthCheckStatus.OK,
                Application = app,
            };
            return Task.FromResult<HealthCheckResults>(healthCheckResults);
        }

        /// <summary>
        /// Creates a placeholder blob and returns the id and url to upload the blob to the storage service.
        /// </summary>
        /// <param name="userId">Id of user creating the blob.</param>
        /// <returns>Id of the blob and the url to upload the audio file to.</returns>
        public async Task<(string id, string url)> BeginAddAudioNote(string userId)
        {
            // generate an ID for this audio note
            var audioId = Guid.NewGuid().ToString();

            // create a blob placeholder (which will not have any content yet)
            var blobUri = await this.blobRepository.GetBlobUploadUrlAsync(AudioBlobContainerName, $"{userId}/{audioId}").ConfigureAwait(false);

            return (audioId, blobUri.ToString());
        }

        /// <summary>
        /// Called after the blob has been uploaded to the container.
        /// </summary>
        /// <param name="audioId">Id of the audio file that has been uploaded.</param>
        /// <param name="userId">Id of the user the audio file is for.</param>
        /// <param name="categoryId">Id of the category the audio file was added to.</param>
        /// <returns>Status for completing the audio note.  Includes 'Success', 'Not Uploaded', and 'Already Created'.</returns>
        public async Task<CompleteAddAudioNoteResult> CompleteAddAudioNoteAsync(string audioId, string userId, string categoryId)
        {
            var blob = await this.blobRepository.GetBlobAsync(AudioBlobContainerName, $"{userId}/{audioId}").ConfigureAwait(false);
            if (blob == null)
            {
                // the blob hasn't actually been uploaded yet, so we can't process it
                return CompleteAddAudioNoteResult.AudioNotUploaded;
            }

            // if the blob already contains metadata then that means it has already been added
            if (blob.Properties.ContainsKey(CategoryIdMetadataName))
            {
                return CompleteAddAudioNoteResult.AudioAlreadyCreated;
            }

            // set the blob metadata
            blob.Properties.Add(CategoryIdMetadataName, categoryId);
            blob.Properties.Add(UserIdMetadataName, userId);
            await this.blobRepository.UpdateBlobPropertiesAsync(blob).ConfigureAwait(false);

            // publish an event into the Event Grid topic
            var subject = $"{userId}/{audioId}";
            await this.eventGridPublisherService.PostEventGridEventAsync(AudioEvents.AudioCreated, subject, new AudioCreatedEventData { Category = categoryId }).ConfigureAwait(false);

            return CompleteAddAudioNoteResult.Success;
        }

        /// <summary>
        /// Gets metadata and URL to download audio file.
        /// </summary>
        /// <param name="id">Id of the audio file.</param>
        /// <param name="userId">Id of the user that uploaded the file.</param>
        /// <returns>Metadata about the audio file and the URL to download.</returns>
        public async Task<AudioNoteDetails> GetAudioNoteAsync(string id, string userId)
        {
            // get the blob, if it exists
            var audioBlob = await this.blobRepository.GetBlobAsync(AudioBlobContainerName, $"{userId}/{id}").ConfigureAwait(false);
            if (audioBlob == null)
            {
                return null;
            }

            Uri blobDownloadUrl = this.blobRepository.GetBlobDownloadUrl(audioBlob);

            return new AudioNoteDetails
            {
                Id = id,
                AudioUrl = blobDownloadUrl,
                Transcript = audioBlob.Properties.ContainsKey(TranscriptMetadataName) ? audioBlob.Properties[TranscriptMetadataName] : null,
            };
        }

        /// <summary>
        /// Gets a list of audio notes for a user.
        /// </summary>
        /// <param name="userId">Id of user to get the audio notes for.</param>
        /// <returns>Collection of audio note summaries.</returns>
        public async Task<AudioNoteSummaryCollection> ListAudioNotesAsync(string userId)
        {
            var blobs = await this.blobRepository.ListBlobsInFolderAsync(AudioBlobContainerName, userId).ConfigureAwait(false);
            var blobSummaries = blobs
                .Select(b => new AudioNoteSummary
                {
                    Id = b.BlobName.Split('/')[1],
                    Preview = b.Properties.ContainsKey(TranscriptMetadataName) ? b.Properties[TranscriptMetadataName].Truncate(TranscriptPreviewLength) : string.Empty,
                })
                .ToList();

            var audioNoteSummaries = new AudioNoteSummaryCollection();
            audioNoteSummaries.AddRange(blobSummaries);

            return audioNoteSummaries;
        }

        /// <summary>
        /// Deletes an audio note from the repository.
        /// </summary>
        /// <param name="id">Id of the blob for the audio note.</param>
        /// <param name="userId">Id of the user that owns the audio note.</param>
        /// <returns>Task for deleting the audio note.</returns>
        public async Task DeleteAudioNoteAsync(string id, string userId)
        {
            // delete the blog
            await this.blobRepository.DeleteBlobAsync(AudioBlobContainerName, $"{userId}/{id}").ConfigureAwait(false);

            // fire an event into the Event Grid topic
            var subject = $"{userId}/{id}";
            await this.eventGridPublisherService.PostEventGridEventAsync(AudioEvents.AudioDeleted, subject, new AudioDeletedEventData()).ConfigureAwait(false);
        }

        /// <summary>
        /// Uses the audio transcription service to transcribe the audio file.
        /// </summary>
        /// <param name="id">Id of the blob containing the audio file.</param>
        /// <param name="userId">Id of the user that owns the audio file.</param>
        /// <returns>A preview of the transcription.</returns>
        public async Task<string> UpdateAudioTranscriptAsync(string id, string userId)
        {
            // get the blob
            var audioBlob = await this.blobRepository.GetBlobAsync(AudioBlobContainerName, $"{userId}/{id}").ConfigureAwait(false);
            if (audioBlob == null)
            {
                return null;
            }

            // Get download url for the blob.
            using MemoryStream blobStream = new MemoryStream();
            await this.blobRepository.CopyBlobToStreamAsync(AudioBlobContainerName, $"{userId}/{id}", blobStream).ConfigureAwait(false);

            // send to Cognitive Services and get back a transcript
            string transcript = await this.audioTranscriptionService.GetAudioTranscriptFromCognitiveServicesAsync(blobStream).ConfigureAwait(false);

            // update the blob's metadata
            audioBlob.Properties[TranscriptMetadataName] = transcript;
            await this.blobRepository.UpdateBlobPropertiesAsync(audioBlob).ConfigureAwait(false);

            // create a preview form of the transcript
            var transcriptPreview = transcript.Truncate(TranscriptPreviewLength);

            // fire an event into the Event Grid topic
            var subject = $"{userId}/{id}";
            await this.eventGridPublisherService.PostEventGridEventAsync(
                AudioEvents.AudioTranscriptUpdated,
                subject,
                new AudioTranscriptUpdatedEventData { TranscriptPreview = transcriptPreview }).ConfigureAwait(false);

            return transcriptPreview;
        }
    }
}
