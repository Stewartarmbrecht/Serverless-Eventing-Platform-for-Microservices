namespace ContentReactor.Common.HealthChecks
{
    using Newtonsoft.Json;

    /// <summary>
    /// Structures the repsonse for a health check.
    /// </summary>
    public class HealthCheckResponse
    {
        /// <summary>
        /// Gets or sets the overall status of the health check.
        /// Will build this out in the future and consider
        /// standardizing this model across all microservices to help
        /// with defining functionality around the health checks.
        /// </summary>
        /// <value>HealthCheckStatus.</value>
        [JsonProperty("status")]
        public HealthCheckStatus Status { get; set; }

        /// <summary>
        /// Gets or sets the name of the application the status is for.
        /// </summary>
        /// <value>String.</value>
        [JsonProperty("application")]
        public string Application { get; set; }
    }
}
