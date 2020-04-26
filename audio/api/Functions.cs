namespace ContentReactor.Audio.Api
{
    using ContentReactor.Common.Blobs;
    using ContentReactor.Common.Events;
    using ContentReactor.Common.UserAuthentication;
    using Microsoft.Extensions.DependencyInjection;

    /// <summary>
    /// Base class for all Audio operations.
    /// </summary>
    public partial class Functions
    {
        /// <summary>
        /// Name of the meta data field that tracks the id of the category the audio file is organized under.
        /// </summary>
        protected internal const string CategoryIdMetadataName = "categoryId";

        /// <summary>
        /// Name of the metadata field that holds the user id.
        /// </summary>
        protected internal const string UserIdMetadataName = "userId";

        /// <summary>
        /// Name of the audio blob container.
        /// </summary>
        protected internal const string AudioBlobContainerName = "audio";

        /// <summary>
        /// Gets or sets the JsonContentType string value.
        /// </summary>
        protected const string JsonContentType = "application/json";

        /// <summary>
        /// Gets the default message for an unhandled exception.
        /// </summary>
        protected const string UnhandledExceptionError = "Unhandled Exception.";

        /// <summary>
        /// Name of meta data field that holds the transcript.
        /// </summary>
        protected const string TranscriptMetadataName = "transcript";

        /// <summary>
        /// Length of the transcript preview.
        /// </summary>
        protected const int TranscriptPreviewLength = 100;

        /// <summary>
        /// Initializes a new instance of the <see cref="Functions"/> class.
        /// </summary>
        /// <param name="userAuthenticationService">The user authentication service to use to identify the calling user.</param>
        /// <param name="blobRepository">The blob respository to use for storing audio files.</param>
        public Functions(
            IUserAuthenticationService userAuthenticationService,
            IBlobRepository blobRepository)
        {
            this.UserAuthenticationService = userAuthenticationService;
            this.BlobRepository = blobRepository;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="Functions"/> class.
        /// </summary>
        /// <param name="userAuthenticationService">The user authentication service to use to identify the calling user.</param>
        /// <param name="blobRepository">The blob respository to use for storing audio files.</param>
        /// <param name="eventGridPublisherService">The event grid publisher service to use for publishing events.</param>
        [ActivatorUtilitiesConstructor]
        public Functions(
            IUserAuthenticationService userAuthenticationService,
            IBlobRepository blobRepository,
            IEventGridPublisherService eventGridPublisherService)
        {
            this.UserAuthenticationService = userAuthenticationService;
            this.BlobRepository = blobRepository;
            this.EventGridPublisherService = eventGridPublisherService;
        }

        /// <summary>
        /// Gets the service that will determine who called the API.
        /// </summary>
        /// <value>An instance of the <see cref="IUserAuthenticationService"/> interface.</value>
        protected IUserAuthenticationService UserAuthenticationService { get; }

        /// <summary>
        /// Gets the service that interacts with the blob store.
        /// </summary>
        /// <value>An instance of the <see cref="IBlobRepository"/> interface.</value>
        protected IBlobRepository BlobRepository { get; }

        /// <summary>
        /// Gets the event grid publisher service.
        /// </summary>
        /// <value>An instance of the <see cref="IEventGridPublisherService"/> interface.</value>
        protected IEventGridPublisherService EventGridPublisherService { get; }
    }
}
