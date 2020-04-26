namespace ContentReactor.Common.Events.Audio
{
    /// <summary>
    /// Audio events type names.
    /// </summary>
    public static class AudioEvents
    {
        /// <summary>
        /// Type for an event when an audio file is created.
        /// </summary>
        /// <returns>String.</returns>
        public const string AudioCreated = nameof(AudioCreated);

        /// <summary>
        /// Type for an event when an audio file is deleted.
        /// </summary>
        /// <returns>String.</returns>
        public const string AudioDeleted = nameof(AudioDeleted);

        /// <summary>
        /// Type for an event when an audio transcript is created.
        /// </summary>
        /// <returns>String.</returns>
        public const string AudioTranscriptUpdated = nameof(AudioTranscriptUpdated);
    }
}
