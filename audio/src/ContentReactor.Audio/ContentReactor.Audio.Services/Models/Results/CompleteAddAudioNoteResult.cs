namespace ContentReactor.Audio.Services.Models.Results
{
    /// <summary>
    /// The result of completing the add of an audio file.
    /// </summary>
    public enum CompleteAddAudioNoteResult
    {
        /// <summary>
        /// The completion was successful.
        /// </summary>
        Success,

        /// <summary>
        /// The audio file was not found.
        /// </summary>
        AudioNotUploaded,

        /// <summary>
        /// The audio file was found to already exist.
        /// </summary>
        AudioAlreadyCreated,
    }
}
