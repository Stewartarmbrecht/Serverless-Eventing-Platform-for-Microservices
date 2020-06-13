namespace ContentReactor.Audio.Service
{
    using System.IO;
    using System.Threading.Tasks;

    /// <summary>
    /// Submits an audio blob to the Cognitive Services Speech API to have it transcribed.
    /// </summary>
    public interface IAudioTranscriptionService
    {
        /// <summary>
        /// Submits an audio blob to the Cognitive Services Speech API to have it transcribed.
        /// </summary>
        /// <param name="audioBlobStream">The audio file blob stream to translate.</param>
        /// <returns>The audio transcription.</returns>
        Task<string> GetAudioTranscriptFromCognitiveServicesAsync(Stream audioBlobStream);
    }
}