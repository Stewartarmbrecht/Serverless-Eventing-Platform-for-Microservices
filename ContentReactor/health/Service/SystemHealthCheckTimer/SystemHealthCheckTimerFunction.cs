namespace ContentReactor.Health.Service
{
    using System;
    using System.Threading.Tasks;
    using Microsoft.Azure.WebJobs;
    using Microsoft.Extensions.Logging;

    /// <summary>
    /// Contains the timer based operation to trigger a system wide health check.
    /// </summary>
    public partial class Functions
    {
        /// <summary>
        /// Performs a timer based call to perform a system wide health check.
        /// </summary>
        /// <param name="timer">The timer info that triggered the function.</param>
        /// <param name="log">Logger to use for logging information or errors.</param>
        /// <returns>Results of the health check.</returns>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Redundancy", "RCS1163", Justification = "Reviewed")]
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Redundancy", "IDE0060", Justification = "Reviewed")]
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA1801", Justification = "Reviewed")]
        [FunctionName("SystemHealthCheckTimer")]
        public async Task SystemHealthCheckTimer(
            [TimerTrigger("0 0/10 * * * *")]TimerInfo timer,
            ILogger log)
        {
            // get the text note
            try
            {
                var document = await this.HealthService.HealthCheck().ConfigureAwait(false);
                if (document == null)
                {
                    log.LogError("No results returned from health check.");
                }
            }
            catch (Exception ex)
            {
                log.LogError(UnhandledExceptionError, ex);
                throw;
            }
        }
    }
}
