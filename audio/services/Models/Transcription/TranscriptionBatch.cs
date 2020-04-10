namespace ContentReactor.Audio.Services.Models
{
    using System;
    using System.Collections.Generic;
    using Newtonsoft.Json;

    /// <summary>
    /// Contains the details of an audio transcription.
    /// </summary>
    public class TranscriptionBatch
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="TranscriptionBatch"/> class.
        /// </summary>
        /// <param name="id">Id of the transcription job.</param>
        /// <param name="name">Name of the transcription job.</param>
        /// <param name="description">Description of the transcription job.</param>
        /// <param name="locale">Locale of the transcription.</param>
        /// <param name="createdDateTime">Date and time the transcription was created.</param>
        /// <param name="lastActionDateTime">Date and time of the last action taken during the transcription.</param>
        /// <param name="status">Status of the transcription.</param>
        /// <param name="recordingsUrl">The URL to the recordings that were transcribed.</param>
        /// <param name="resultsUrls">The URLs to the segmented transcriptions.</param>
        [JsonConstructor]
        public TranscriptionBatch(
            Guid id,
            string name,
            string description,
            string locale,
            DateTime createdDateTime,
            DateTime lastActionDateTime,
            string status,
            Uri recordingsUrl,
            IReadOnlyDictionary<string, string> resultsUrls)
        {
            this.Id = id;
            this.Name = name;
            this.Description = description;
            this.CreatedDateTime = createdDateTime;
            this.LastActionDateTime = lastActionDateTime;
            this.Status = status;
            this.Locale = locale;
            this.RecordingsUrl = recordingsUrl;
            this.ResultsUrls = resultsUrls;
        }

        /// <summary>
        /// Gets or sets the name of the transcription.
        /// </summary>
        /// <value>The name of the transcription.</value>
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the description of the transcription.
        /// </summary>
        /// <value>The description of the transcription.</value>
        public string Description { get; set; }

        /// <summary>
        /// Gets or sets the locale for the transcription.
        /// </summary>
        /// <value>The locale for the trasncription.</value>
        public string Locale { get; set; }

        /// <summary>
        /// Gets or sets the Url to the audio recording.
        /// </summary>
        /// <value>The URL to the audio recording.</value>
        public Uri RecordingsUrl { get; set; }

        /// <summary>
        /// Gets or sets the list of URLs to the transcription results.
        /// </summary>
        /// <value>The list of transcription results.</value>
        public IReadOnlyDictionary<string, string> ResultsUrls { get; set; }

        /// <summary>
        /// Gets or sets the unique id of the transcription.
        /// </summary>
        /// <value>The unique id of the transcription.</value>
        public Guid Id { get; set; }

        /// <summary>
        /// Gets or sets the date and time the transcription batch was generated.
        /// </summary>
        /// <value>The date and time the transcription batch was created.</value>
        public DateTime CreatedDateTime { get; set; }

        /// <summary>
        /// Gets or sets the date and time of the last action.
        /// </summary>
        /// <value>The date and time of the last action performed on the transcription.</value>
        public DateTime LastActionDateTime { get; set; }

        /// <summary>
        /// Gets or sets the status of the transcription batch.
        /// </summary>
        /// <value>The status of the transcription batch job.</value>
        public string Status { get; set; }

        /// <summary>
        /// Gets or sets the status message for the transcription batch status.
        /// </summary>
        /// <value>The message to explain the status of the transceription batch.</value>
        public string StatusMessage { get; set; }
    }
}
