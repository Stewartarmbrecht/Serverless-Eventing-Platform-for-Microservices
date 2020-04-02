namespace ContentReactor.Audio.Services
{
    using System.Threading.Tasks;
    using ContentReactor.Audio.Services.Models.Responses;
    using ContentReactor.Audio.Services.Models.Results;
    using ContentReactor.Common;

    /// <summary>
    /// Provides operations for managing audio files.
    /// </summary>
    public interface IAudioService
    {
        /// <summary>
        /// Performas a health check of all depdendencies of the API service.
        /// </summary>
        /// <param name="userId">Id of the user performing the health check.</param>
        /// <param name="app">Name of the hosting environment.</param>
        /// <returns>Results of the health check. An instance of the <see cref="HealthCheckResults"/> class.</returns>
        Task<HealthCheckResults> HealthCheckApi(string userId, string app);

        /// <summary>
        /// Performas a health check of all depdendencies of the worker service.
        /// </summary>
        /// <param name="userId">Id of the user performing the health check.</param>
        /// <param name="app">Name of the hosting environment.</param>
        /// <returns>Results of the health check. An instance of the <see cref="HealthCheckResults"/> class.</returns>
        Task<HealthCheckResults> HealthCheckWorker(string userId, string app);

        /// <summary>
        /// Creates a placeholder blob and returns the id and URL to upload the actual audio file.
        /// </summary>
        /// <param name="userId">Id of the user creating the blob.</param>
        /// <returns>Id of the new blog and URL to upload the blob to.</returns>
        Task<(string id, string url)> BeginAddAudioNote(string userId);

        /// <summary>
        /// Called after the blob has been uploaded to the container.
        /// </summary>
        /// <param name="audioId">Id of the audio file that has been uploaded.</param>
        /// <param name="userId">Id of the user the audio file is for.</param>
        /// <param name="categoryId">Id of the category the audio file was added to.</param>
        /// <returns>Results for completing the add of an audiot note. An instnace of the <see cref="CompleteAddAudioNoteResult"/> class.</returns>
        Task<CompleteAddAudioNoteResult> CompleteAddAudioNoteAsync(string audioId, string userId, string categoryId);

        /// <summary>
        /// Gets metadata and URL to download audio file.
        /// </summary>
        /// <param name="id">Id of the audio file.</param>
        /// <param name="userId">Id of the user that uploaded the file.</param>
        /// <returns>Metadata about the audio file and the URL to download.</returns>
        Task<AudioNoteDetails> GetAudioNoteAsync(string id, string userId);

        /// <summary>
        /// Gets a list of audio notes for a user.
        /// </summary>
        /// <param name="userId">Id of user to get the audio notes for.</param>
        /// <returns>Collection of audio note summaries.</returns>
        Task<AudioNoteSummaryCollection> ListAudioNotesAsync(string userId);

        /// <summary>
        /// Deletes an audio note from the repository.
        /// </summary>
        /// <param name="id">Id of the blob for the audio note.</param>
        /// <param name="userId">Id of the user that owns the audio note.</param>
        /// <returns>Task for deleting the audio note.</returns>
        Task DeleteAudioNoteAsync(string id, string userId);

        /// <summary>
        /// Uses the audio transcription service to transcribe the audio file.
        /// </summary>
        /// <param name="id">Id of the blob containing the audio file.</param>
        /// <param name="userId">Id of the user that owns the audio file.</param>
        /// <returns>A preview of the transcription.</returns>
        Task<string> UpdateAudioTranscriptAsync(string id, string userId);
    }
}