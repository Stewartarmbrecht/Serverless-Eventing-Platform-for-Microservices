namespace ContentReactor.Audio.Service.Tests.Unit
{
    using System.Threading.Tasks;
    using ContentReactor.Common.Events;
    using ContentReactor.Common.Events.Audio;
    using ContentReactor.Common.Fakes;
    using ContentReactor.Common.UserAuthentication;
    using Microsoft.AspNetCore.Http;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Extensions.Logging;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Moq;

    /// <summary>
    /// Contains unit tests for the Audio Service delete operation.
    /// </summary>
    [TestClass]
    public class DeleteFunctionTests
    {
        /// <summary>
        /// Given you have an audio api with a blob
        /// When you call the delete audio operation
        /// Then it should delete the blob from the repository.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task WithSuccessDeletesBlob()
        {
            // arrange
            Mock<ILogger> mockLogger = new Mock<ILogger>();
            var mockRequest = Mockers.MockRequest(null);
            var sut = AudioMockers.GetApiFunctionsWithBlobUploaded();

            // act
            var response = await sut.Delete(mockRequest.Object, mockLogger.Object, Mockers.DefaultId).ConfigureAwait(false);
            var responseType = (NoContentResult)response;

            // assert
            Assert.IsNotNull(responseType);
        }

        /// <summary>
        /// Given you have an audio api with a blob
        /// When you call the audio delete operation
        /// Then it should raise the AudioDeleted event.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task WithSuccessPublishesAudioDeletedEventToEventGrid()
        {
            // arrange
            Mock<ILogger> mockLogger = new Mock<ILogger>();
            var mockRequest = Mockers.MockRequest(null);
            var sut = AudioMockers.GetApiFunctionsWithBlobUploaded(
                out FakeBlobRepository fakeBlobRepo,
                out Mock<IEventGridPublisherService> mockEventGridPublisherService);

            // act
            var response = await sut.Delete(mockRequest.Object, mockLogger.Object, Mockers.DefaultId).ConfigureAwait(false);
            var responseType = (NoContentResult)response;

            // assert
            mockEventGridPublisherService.Verify(
                m => m.PostEventGridEventAsync(
                    AudioEvents.AudioDeleted,
                    "fakeuserid/fakeid",
                    It.IsAny<AudioDeletedEventData>()),
                Times.Once);
        }

        /// <summary>
        /// Given you have an audio api with no blobs
        /// When you call the delete operation
        /// Then it should not throw an exception.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task WithInvalidAudioIdReturnsAudioNotFound()
        {
            // arrange
            Mock<ILogger> mockLogger = new Mock<ILogger>();
            var mockRequest = Mockers.MockRequest(null);
            var sut = AudioMockers.GetApiFunctionsWithBlobUploaded(
                out FakeBlobRepository fakeBlobRepo);

            fakeBlobRepo.Blobs.Clear();

            // act
            var response = await sut.Delete(mockRequest.Object, mockLogger.Object, Mockers.DefaultId).ConfigureAwait(false);
            var responseType = (NoContentResult)response;

            // assert
            Assert.IsNotNull(responseType);
        }

        /// <summary>
        /// Given you have an audio api with a blob
        /// When you call the delete audio operation with the wrong user id
        /// Then it should execute, do nothing, and not raise an exception.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task WithIncorrectUserIdReturnsAudioNotFound()
        {
            // arrange
            Mock<ILogger> mockLogger = new Mock<ILogger>();
            var mockRequest = Mockers.MockRequest(null);
            var sut = AudioMockers.GetApiFunctionsWithBlobUploaded(
                out FakeBlobRepository fakeBlobRepo);

            fakeBlobRepo.Blobs.Clear();
            fakeBlobRepo.AddFakeBlob(Mockers.AudioContainerName, $"otheruserid/{Mockers.DefaultId}");

            // act
            var response = await sut.Delete(mockRequest.Object, mockLogger.Object, Mockers.DefaultId).ConfigureAwait(false);
            var responseType = (NoContentResult)response;

            // assert
            Assert.IsNotNull(responseType);
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
            var response = await sut.Delete(mockRequest.Object, mockLogger.Object, Mockers.DefaultId).ConfigureAwait(false);
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
            await Assert.ThrowsExceptionAsync<System.Exception>(() => sut.Delete(mockRequest.Object, mockLogger.Object, Mockers.DefaultId)).ConfigureAwait(false);

            mockLogger.Verify(moc => moc.Log(LogLevel.Error, It.IsAny<System.Exception>(), "Unhandled Exception."));
        }
    }
}
