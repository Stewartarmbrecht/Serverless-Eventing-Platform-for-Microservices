namespace ContentReactor.Health.Service.Tests.Unit
{
    using System.Collections.Generic;
    using System.Threading.Tasks;
    using ContentReactor.Common.Fakes;
    using ContentReactor.Common.HealthChecks;
    using ContentReactor.Common.UserAuthentication;
    using ContentReactor.Health.Service;
    using Microsoft.AspNetCore.Http;
    using Microsoft.Azure.WebJobs;
    using Microsoft.Azure.WebJobs.Extensions.Timers;
    using Microsoft.Extensions.Logging;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Moq;

    /// <summary>
    /// Contains unit tests for the System Health Check Timer function.
    /// </summary>
    [TestClass]
    public class SystemHealthCheckTimerFunctionTests
    {
        /// <summary>
        /// Given you have a healthy running system
        /// When you the system health check timer function fires
        /// Then it should return a collection of successful health check statuses returned by the HealthCheckService instance.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task WithSuccess()
        {
            // arrange
            Mock<ILogger> mockLogger = new Mock<ILogger>();
            var mockRequest = Mockers.MockRequest(null);
            mockRequest.Setup(x => x.Host).Returns(new HostString("test"));
            var sut = HealthMockers.GetApiFunctions(
                out Mock<IUserAuthenticationService> mockUserAuthenticationService,
                out Mock<IHealthService> mockHealthService);

            mockHealthService.Setup(x => x.HealthCheck()).ReturnsAsync(new List<HealthCheckResponse>()
            {
                new HealthCheckResponse()
                {
                    Application = "Ali",
                    Status = HealthCheckStatus.OK,
                },
                new HealthCheckResponse()
                {
                    Application = "Baba",
                    Status = HealthCheckStatus.OK,
                },
            });

            // act
            await sut.SystemHealthCheck(mockRequest.Object, mockLogger.Object).ConfigureAwait(false);

            // assert
            mockHealthService.Verify(x => x.HealthCheck(), Times.Once);
        }

        /// <summary>
        /// Given you have a service instance running
        /// When you call the health check operation
        /// And a sub-component throws and exception
        /// Then it should log the exception and throw it.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Globalization", "CA1303", Justification="Reviewed")]
        [TestMethod]
        public async Task WithThrownExceptionThrowsException()
        {
            // arrange
            Mock<AbstractLogger> mockLogger = new Mock<AbstractLogger>();
            TimerInfo timerInfo = Mockers.GetTimerInfo();
            var sut = HealthMockers.GetApiFunctions(
                out Mock<IUserAuthenticationService> mockUserAuth,
                out Mock<IHealthService> mockHealthService);

            System.Exception ex = new System.Exception("My error.");
            mockHealthService.Setup(m => m.HealthCheck())
                .ThrowsAsync(ex);

            // act
            await Assert.ThrowsExceptionAsync<System.Exception>(() => sut.SystemHealthCheckTimer(timerInfo, mockLogger.Object)).ConfigureAwait(false);

            mockLogger.Verify(moc => moc.Log(LogLevel.Error, It.IsAny<System.Exception>(), "Unhandled Exception."));
        }
    }
}
