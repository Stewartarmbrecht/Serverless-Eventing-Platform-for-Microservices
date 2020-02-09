using System.Collections.Generic;
using Newtonsoft.Json;

namespace ContentReactor.Categories.Services.Models.Response
{
    /// <summary>
    /// Structures the repsonse for a health check.
    /// </summary>
    public class HealthCheckResults
    {
        /// <summary>
        /// The overall status of the health check.
        /// Will build this out in the future and consider
        /// standardizing this model across all microservices to help 
        /// with defining functionality around the health checks.
        /// </summary>
        /// <value></value>
        [JsonProperty("status")]
        public HealthCheckStatus Status { get; set; }
    }

    /// <summary>
    /// List of valid statuses for a health check.
    /// </summary>
    public enum HealthCheckStatus {
        /// <summary>
        /// Everything is ok.
        /// </summary>
        OK,
        /// <summary>
        /// Some issues were detected that could cause an error in the future 
        /// or did create an issue in the past but are not causing an issue
        /// right now.
        /// </summary>
        Warning,
        /// <summary>
        /// An issue was detected that could prevent proper functioning.
        /// </summary>
        Error
    }
}
