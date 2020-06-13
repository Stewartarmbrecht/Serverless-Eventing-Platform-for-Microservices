namespace ContentReactor.Health
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Net.Http;
    using System.Threading.Tasks;
    using ContentReactor.Common.HealthChecks;

    /// <summary>
    /// Interface for the health check service.
    /// </summary>
    public interface IHealthService
    {
        /// <summary>
        /// Performs health checks on all applications in the system.
        /// </summary>
        /// <returns>List of health check repsonses.</returns>
        Task<List<HealthCheckResponse>> HealthCheck();
    }
}
