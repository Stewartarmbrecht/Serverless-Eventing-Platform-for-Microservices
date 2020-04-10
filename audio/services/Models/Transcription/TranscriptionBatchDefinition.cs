namespace ContentReactor.Audio.Services.Models
{
    using System;
    using System.Collections.Generic;

    /// <summary>
    /// Captures the necessary data points to define a transcription request.
    /// </summary>
    public sealed class TranscriptionBatchDefinition
    {
        private TranscriptionBatchDefinition(
            string name,
            string description,
            string locale,
            Uri recordingsUrl,
            IEnumerable<ModelIdentity> models)
        {
            this.Name = name;
            this.Description = description;
            this.RecordingsUrl = recordingsUrl;
            this.Locale = locale;
            this.Models = models;
            this.Properties = new Dictionary<string, string>
            {
                ["PunctuationMode"] = "DictatedAndAutomatic",
                ["ProfanityFilterMode"] = "Masked",
                ["AddWordLevelTimestamps"] = "True",
            };
        }

        /// <summary>
        /// Gets or sets the user defined name of the transcription batch.
        /// </summary>
        /// <value>The name of the transcription job.</value>
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the optional description of the transcription.
        /// </summary>
        /// <value>The description of the transcription batch.</value>
        public string Description { get; set; }

        /// <summary>
        /// Gets or sets the URL to the Azure blob to transcribe.
        /// </summary>
        /// <value>The URL to the azure blob to transcribe.</value>
        public Uri RecordingsUrl { get; set; }

        /// <summary>
        /// Gets or sets the locale to use, for example en-US.
        /// </summary>
        /// <value>The locale to use for the transcription.</value>
        public string Locale { get; set; }

        /// <summary>
        /// Gets or sets the list of models to use when transcribing the audio blob.
        /// </summary>
        /// <value>The specific models that should be used to transcibe the audio file.</value>
        public IEnumerable<ModelIdentity> Models { get; set; }

        /// <summary>
        /// Gets the properties that drive the transcription in the speech recognition api.
        /// See the <see href="https://docs.microsoft.com/en-us/azure/cognitive-services/speech-service/batch-transcription">Microsoft Documentation</see>.
        /// </summary>
        /// <value>Dictionary{string, string} of properties.</value>
        public IDictionary<string, string> Properties { get; }

        /// <summary>
        /// Creates a new instance of the TranscriptionBatchDefinition class.
        /// </summary>
        /// <param name="name">User defined name of the transcription batch.</param>
        /// <param name="description">Optional description of the transcription.</param>
        /// <param name="locale">Locale to use, for example en-US.</param>
        /// <param name="recordingsUrl">The url to the recording to transcribe.</param>
        /// <returns>The instance of the transcription batch job definition.</returns>
        public static TranscriptionBatchDefinition Create(
            string name,
            string description,
            string locale,
            Uri recordingsUrl)
            => new TranscriptionBatchDefinition(name, description, locale, recordingsUrl, Array.Empty<ModelIdentity>());
    }
}
