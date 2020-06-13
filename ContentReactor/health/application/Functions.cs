namespace ContentReactor.Health
{
    using ContentReactor.Common.UserAuthentication;
    using Microsoft.Extensions.DependencyInjection;

    /// <summary>
    /// Base class for all Audio operations.
    /// </summary>
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1724", Justification = "Reviewed")]
    public partial class Functions
    {
        /// <summary>
        /// Name of the metadata field that holds the user id.
        /// </summary>
        protected internal const string UserIdMetadataName = "userId";

        /// <summary>
        /// Gets or sets the JsonContentType string value.
        /// </summary>
        protected const string JsonContentType = "application/json";

        /// <summary>
        /// Gets the default message for an unhandled exception.
        /// </summary>
        protected const string UnhandledExceptionError = "Unhandled Exception.";

        /// <summary>
        /// Initializes a new instance of the <see cref="Functions"/> class.
        /// </summary>
        /// <param name="userAuthenticationService">The user authentication service to use to identify the calling user.</param>
        [ActivatorUtilitiesConstructor]
        public Functions(
            IUserAuthenticationService userAuthenticationService)
        {
            this.UserAuthenticationService = userAuthenticationService;
        }

        /// <summary>
        /// Gets the service that will determine who called the API.
        /// </summary>
        /// <value>An instance of the <see cref="IUserAuthenticationService"/> interface.</value>
        protected IUserAuthenticationService UserAuthenticationService { get; }

        /// <summary>
        /// Gets the service that implements the health check operation.
        /// </summary>
        /// <value>An instance of the <see cref="ContentReactor.Common.HealthChecks.HealthCheckResponse"/> class.</value>
        protected IHealthService HealthService { get; }
    }
}
