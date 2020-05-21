namespace ContentReactor.Common.HealthChecks
{
    /// <summary>
    /// List of valid statuses for a health check.
    /// </summary>
    public enum HealthCheckStatus
    {
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
        Error,
    }
}
