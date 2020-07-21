namespace ContentReactor.Audio.Service.Tests.Unit
{
    using System;
    using System.Threading.Tasks;
    using ContentReactor.Audio.Service;
    using ContentReactor.Common.Events;
    using ContentReactor.Common.Fakes;
    using ContentReactor.Common.HealthChecks;
    using ContentReactor.Common.UserAuthentication;
    using Microsoft.AspNetCore.Http;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Extensions.Logging;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Moq;

    /// <summary>
    /// Contains unit tests for the Audio Service get opreations.
    /// </summary>
    [TestClass]
    public class HealthCheckFunctionTests
    {
        /// <summary>
        /// Given you have an audio api
        /// And the blob storage check fails
        /// When you call the health check function
        /// Then it should return a failed health check status
        /// And it should contain an error explaining that the blob storage check failed.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task WithBlobStorageFailing()
        {
            // arrange
            Mock<ILogger> mockLogger = new Mock<ILogger>();
            var mockRequest = Mockers.MockRequest(null);
            mockRequest.Setup(x => x.Host).Returns(new HostString("test"));
            var sut = AudioMockers.GetApiFunctionsWithBlobUploaded(
                out FakeBlobRepository fakeBlobRepo);

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
        /// Given you have an audio api
        /// When you call the delete operation without a user id
        /// Then it should return a bad request with the error returned by the user authentication service.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task WithMissingUserIdReturnsBadRequest()
        {
            // arrange
            string userId;
            var fakeRepository = new FakeBlobRepository();
            Mock<ILogger> mockLogger = new Mock<ILogger>();
            var mockRequest = Mockers.MockRequest(null);
            var sut = AudioMockers.GetApiFunctionsWithBlobUploaded(
                out Mock<IUserAuthenticationService> mockUserAuth,
                out FakeBlobRepository fakeBlobRepo,
                out Mock<IEventGridPublisherService> mockEventGridPublisherService);

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
        /// Given you have an audio api
        /// When you call the delete operation
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
            var fakeRepository = new FakeBlobRepository();
            Mock<AbstractLogger> mockLogger = new Mock<AbstractLogger>();
            var mockRequest = AudioMockers.GetMockAddCompleteRequest();
            var sut = AudioMockers.GetApiFunctionsWithBlobUploaded(
                out Mock<IUserAuthenticationService> mockUserAuth,
                out FakeBlobRepository fakeBlobRepo,
                out Mock<IEventGridPublisherService> mockEventGridPublisherService);

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
