namespace ContentReactor.Audio.Services
{
    using ContentReactor.Audio.Services.Models.Responses;
    using ContentReactor.Audio.Services.Models.Results;
    using System;
    using System.Collections.Generic;
    using System.Text;
    using System.Threading.Tasks;

    /// <summary>
    /// Provides operations for managing audio files.
    /// </summary>
    public interface IAudioService
    {
        /// <summary>
        /// Creates a placeholder blob and returns the id and URL to upload the actual audio file.
        /// </summary>
        /// <param name="userId">Id of the user creating the blob.</param>
        /// <returns>Id of the new blog and URL to pose the blob to.</returns>
        (string id, string url) BeginAddAudioNote(string userId);

        /// <summary>
        /// 
        /// </summary>
        /// <param name="audioId"></param>
        /// <param name="userId"></param>
        /// <param name="categoryId"></param>
        /// <returns></returns>
        Task<CompleteAddAudioNoteResult> CompleteAddAudioNoteAsync(string audioId, string userId, string categoryId);

        Task<AudioNoteDetails> GetAudioNoteAsync(string id, string userId);

        Task<AudioNoteSummaryCollection> ListAudioNotesAsync(string userId);

        Task DeleteAudioNoteAsync(string id, string userId);

        Task<string> UpdateAudioTranscriptAsync(string id, string userId);
    }

}
