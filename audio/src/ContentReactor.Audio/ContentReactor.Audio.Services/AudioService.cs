namespace ContentReactor.Audio.Services
{
    using System;
    using System.IO;
    using System.Linq;
    using System.Threading.Tasks;
    using ContentReactor.Audio.Services.Models.Responses;
    using ContentReactor.Audio.Services.Models.Results;
    using ContentReactor.Shared;
    using ContentReactor.Shared.BlobRepository;
    using ContentReactor.Shared.EventSchemas.Audio;
    using Microsoft.WindowsAzure.Storage.Blob;

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

        private IBlobRepository blobRepository;
        private IAudioTranscriptionService audioTranscriptionService;
        private IEventGridPublisherService eventGridPublisherService;

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
        /// Creates a placeholder blob and returns the id and url to update the blob.
        /// </summary>
        /// <param name="userId">Id of user creating the blob.</param>
        /// <returns>Id of the blog and the url to upload the audio file to.</returns>
        public (string id, string url) BeginAddAudioNote(string userId)
        {
            // generate an ID for this audio note
            var audioId = Guid.NewGuid().ToString();

            // create a blob placeholder (which will not have any content yet)
            var blob = this.blobRepository.CreatePlaceholderBlob(AudioBlobContainerName, userId, audioId);

            // get a SAS token to allow the client to write the blob
            var writePolicy = new SharedAccessBlobPolicy
            {
                SharedAccessStartTime = DateTime.UtcNow.AddMinutes(-5), // to allow for clock skew
                SharedAccessExpiryTime = DateTime.UtcNow.AddHours(24),
                Permissions = SharedAccessBlobPermissions.Create | SharedAccessBlobPermissions.Write
            };
            var url = this.blobRepository.GetSasTokenForBlob(blob, writePolicy);

            return (audioId, url);
        }

        /// <summary>
        /// Called after the blob has been uploaded to the container.
        /// </summary>
        /// <param name="audioId">Id of the audio file that has been uploaded.</param>
        /// <param name="userId">Id of the user the audio file is for.</param>
        /// <param name="categoryId">Id of the category the audio file was added to.</param>
        /// <returns>CompleteAddAudioNoteResult</returns>
        public async Task<CompleteAddAudioNoteResult> CompleteAddAudioNoteAsync(string audioId, string userId, string categoryId)
        {
            var imageBlob = await this.blobRepository.GetBlobAsync(AudioBlobContainerName, userId, audioId, true).ConfigureAwait(false);
            if (imageBlob == null || !await this.blobRepository.BlobExistsAsync(imageBlob).ConfigureAwait(false))
            {
                // the blob hasn't actually been uploaded yet, so we can't process it
                return CompleteAddAudioNoteResult.AudioNotUploaded;
            }

            // if the blob already contains metadata then that means it has already been added
            if (imageBlob.Metadata.ContainsKey(CategoryIdMetadataName))
            {
                return CompleteAddAudioNoteResult.AudioAlreadyCreated;
            }

            // set the blob metadata
            imageBlob.Metadata.Add(CategoryIdMetadataName, categoryId);
            imageBlob.Metadata.Add(UserIdMetadataName, userId);
            await this.blobRepository.UpdateBlobMetadataAsync(imageBlob).ConfigureAwait(false);

            // publish an event into the Event Grid topic
            var subject = $"{userId}/{audioId}";
            await this.eventGridPublisherService.PostEventGridEventAsync(EventTypes.Audio.AudioCreated, subject, new AudioCreatedEventData { Category = categoryId }).ConfigureAwait(false);

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
            var audioBlob = await this.blobRepository.GetBlobAsync(AudioBlobContainerName, userId, id, true).ConfigureAwait(false);
            if (audioBlob == null)
            {
                return null;
            }

            // get a SAS token for the blob
            var readPolicy = new SharedAccessBlobPolicy
            {
                SharedAccessStartTime = DateTime.UtcNow.AddMinutes(-5), // to allow for clock skew
                SharedAccessExpiryTime = DateTime.UtcNow.AddHours(24),
                Permissions = SharedAccessBlobPermissions.Read
            };
            var audioUrl = new Uri(this.blobRepository.GetSasTokenForBlob(audioBlob, readPolicy));

            // get the transcript out of the blob metadata
            audioBlob.Metadata.TryGetValue(TranscriptMetadataName, out var transcript);

            return new AudioNoteDetails 
            {
                Id = id,
                AudioUrl = audioUrl,
                Transcript = transcript
            };
        }

        /// <summary>
        /// Gets a list of audio notes for a user.
        /// </summary>
        /// <param name="userId">Id of user to get the audio notes for.</param>
        /// <returns>AudioNoteSummaryCollection</returns>
        public async Task<AudioNoteSummaryCollection> ListAudioNotesAsync(string userId)
        {
            var blobs = await this.blobRepository.ListBlobsInFolderAsync(AudioBlobContainerName, userId).ConfigureAwait(false);
            var blobSummaries = blobs
                .Select(b => new AudioNoteSummary
                {
                    Id = b.Name.Split('/')[1], 
                    Preview = b.Metadata.ContainsKey(TranscriptMetadataName) ? b.Metadata[TranscriptMetadataName].Truncate(TranscriptPreviewLength) : string.Empty
                })
                .ToList();

            var audioNoteSummaries = new AudioNoteSummaryCollection();
            audioNoteSummaries.AddRange(blobSummaries);

            return audioNoteSummaries;
        }

        public async Task DeleteAudioNoteAsync(string id, string userId)
        {
            // delete the blog
            await blobRepository.DeleteBlobAsync(AudioBlobContainerName, userId, id);

            // fire an event into the Event Grid topic
            var subject = $"{userId}/{id}";
            await eventGridPublisherService.PostEventGridEventAsync(EventTypes.Audio.AudioDeleted, subject, new AudioDeletedEventData());
        }

        public async Task<string> UpdateAudioTranscriptAsync(string id, string userId)
        {
            // get the blob
            var audioBlob = await blobRepository.GetBlobAsync(AudioBlobContainerName, userId, id, true);
            if (audioBlob == null)
            {
                return null;
            }

            // download file to MemoryStream
            string transcript;
            using (var audioBlobStream = new MemoryStream())
            {
                await blobRepository.DownloadBlobAsync(audioBlob, audioBlobStream);

                // send to Cognitive Services and get back a transcript
                transcript = await audioTranscriptionService.GetAudioTranscriptFromCognitiveServicesAsync(audioBlobStream);
            }
            
            // update the blob's metadata
            audioBlob.Metadata[TranscriptMetadataName] = transcript;
            await blobRepository.UpdateBlobMetadataAsync(audioBlob);

            // create a preview form of the transcript
            var transcriptPreview = transcript.Truncate(TranscriptPreviewLength);

            // fire an event into the Event Grid topic
            var subject = $"{userId}/{id}";
            await eventGridPublisherService.PostEventGridEventAsync(EventTypes.Audio.AudioTranscriptUpdated, subject, new AudioTranscriptUpdatedEventData { TranscriptPreview = transcriptPreview });

            return transcriptPreview;
        }
    }
}
