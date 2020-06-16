namespace ContentReactor.Health.Service.Tests.Unit
{
    using System.Threading.Tasks;
    using ContentReactor.Common.Fakes;
    using ContentReactor.Common.HealthChecks;
    using ContentReactor.Common.UserAuthentication;
    using ContentReactor.Health.Service;
    using Microsoft.AspNetCore.Http;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Extensions.Logging;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Moq;

    /// <summary>
    /// Contains unit tests for the Health Check function.
    /// </summary>
    [TestClass]
    public class HealthCheckFunctionTests
    {
        /// <summary>
        /// Given you have a healthy running health service
        /// When you call the health check function
        /// Then it should return a successful health check status.
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

            // act
            var response = await sut.HealthCheck(mockRequest.Object, mockLogger.Object).ConfigureAwait(false);
            var responseType = (OkObjectResult)response;
            var responseObject = (HealthCheckResponse)responseType.Value;

            // assert
            Assert.IsNotNull(responseObject);
            Assert.AreEqual(HealthCheckStatus.OK, responseObject.Status);
            Assert.AreEqual("test", responseObject.Application);
        }

        /// <summary>
        /// Given you have a service instance
        /// When you call the health check operation without a user id
        /// Then it should return a bad request with the error returned by the user authentication service.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task WithMissingUserIdReturnsBadRequest()
        {
            // arrange
            string userId;
            Mock<ILogger> mockLogger = new Mock<ILogger>();
            var mockRequest = Mockers.MockRequest(null);
            mockRequest.Setup(x => x.Host).Returns(new HostString("test"));
            var sut = HealthMockers.GetApiFunctions(
                out Mock<IUserAuthenticationService> mockUserAuth,
                out Mock<IHealthService> mockHealthService);

            IActionResult actionResult = new BadRequestObjectResult(new { error = "Error." });
            mockUserAuth.Setup(m => m.GetUserIdAsync(It.IsAny<HttpRequest>(), out userId, out actionResult))
                .Returns(Task.FromResult(false));

            // act
            var response = await sut.HealthCheck(mockRequest.Object, mockLogger.Object).ConfigureAwait(false);
            var objectResult = (BadRequestObjectResult)response;
            var addResponse = (dynamic)objectResult.Value;

            // assert
            Assert.AreEqual("Error.", addResponse.error);
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
            string userId;
            Mock<AbstractLogger> mockLogger = new Mock<AbstractLogger>();
            var mockRequest = Mockers.MockRequest(null);
            mockRequest.Setup(x => x.Host).Returns(new HostString("test"));
            var sut = HealthMockers.GetApiFunctions(
                out Mock<IUserAuthenticationService> mockUserAuth,
                out Mock<IHealthService> mockHealthService);

            IActionResult actionResult = new BadRequestObjectResult(new { error = "Error." });
            System.Exception ex = new System.Exception("My error.");
            mockUserAuth.Setup(m => m.GetUserIdAsync(It.IsAny<HttpRequest>(), out userId, out actionResult))
                .ThrowsAsync(ex);

            // act
            await Assert.ThrowsExceptionAsync<System.Exception>(() => sut.HealthCheck(mockRequest.Object, mockLogger.Object)).ConfigureAwait(false);

            mockLogger.Verify(moc => moc.Log(LogLevel.Error, It.IsAny<System.Exception>(), "Unhandled Exception."));
        }
    }
}
