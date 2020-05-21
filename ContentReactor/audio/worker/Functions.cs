namespace ContentReactor.Audio.Worker
{
    using ContentReactor.Common.Blobs;
    using ContentReactor.Common.Events;
    using ContentReactor.Common.Events.Audio;
    using ContentReactor.Common.UserAuthentication;

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
        /// The ContentType value for Json content.
        /// </summary>
        private const string JsonContentType = "application/json";

        /// <summary>
        /// The message to return when the system experiences an unhandled exception.
        /// </summary>
        private const string UnhandledExceptionError = "Unhandled Exception.";

        /// <summary>
        /// The name of the azure storage blob container that stores the audio files.
        /// </summary>
        private const string AudioBlobContainerName = "audio";

        /// <summary>
        /// Name of meta data field that holds the transcript.
        /// </summary>
        private const string TranscriptMetadataName = "transcript";

        /// <summary>
        /// Length of the transcript preview.
        /// </summary>
        private const int TranscriptPreviewLength = 100;

        /// <summary>
        /// Initializes a new instance of the <see cref="Functions"/> class.
        /// </summary>
        /// <param name="userAuthenticationService">The user authentication service to use.</param>
        /// <param name="eventGridSubscriberService">The event grid subscriber service to use for processing event grid events.</param>
        /// <param name="eventGridPublisherService">The event grid publisher service to use for publishing events.</param>
        /// <param name="blobRepository">The blob respository to use for storing audio files.</param>
        /// <param name="audioTranscriptionService">The audio transcription service to use for transcribing audio files.</param>
        public Functions(
            IUserAuthenticationService userAuthenticationService,
            IEventGridSubscriberService eventGridSubscriberService,
            IEventGridPublisherService eventGridPublisherService,
            IBlobRepository blobRepository,
            IAudioTranscriptionService audioTranscriptionService)
        {
            this.UserAuthenticationService = userAuthenticationService;
            this.EventGridSubscriberService = eventGridSubscriberService;
            this.EventGridPublisherService = eventGridPublisherService;
            this.BlobRepository = blobRepository;
            this.AudioTranscriptionService = audioTranscriptionService;
        }

        /// <summary>
        /// Gets the user authentication service to use to authenticate users.
        /// </summary>
        /// <value>An instnace of the <see cref="IUserAuthenticationService"/> interface.</value>
        private IUserAuthenticationService UserAuthenticationService { get; }

        /// <summary>
        /// Gets the event grid subscriber service to use to process event grid events.
        /// </summary>
        /// <value>An instnace of the <see cref="IEventGridSubscriberService"/> interface.</value>
        private IEventGridSubscriberService EventGridSubscriberService { get; }

        /// <summary>
        /// Gets the event grid publisher service to use to publish event grid events.
        /// </summary>
        /// <value>An instnace of the <see cref="IEventGridPublisherService"/> interface.</value>
        private IEventGridPublisherService EventGridPublisherService { get; }

        /// <summary>
        /// Gets the blob repository to use to store audio blobs.
        /// </summary>
        /// <value>An instnace of the <see cref="IBlobRepository"/> interface.</value>
        private IBlobRepository BlobRepository { get; }

        /// <summary>
        /// Gets the transcription service to use to transcribe audio files.
        /// </summary>
        /// <value>An instnace of the <see cref="IAudioTranscriptionService"/> interface.</value>
        private IAudioTranscriptionService AudioTranscriptionService { get; }
    }
}
