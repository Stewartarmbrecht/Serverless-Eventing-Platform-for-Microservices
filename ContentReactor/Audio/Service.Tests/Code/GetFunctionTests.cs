namespace ContentReactor.Audio.Service.Tests.Unit
{
    using System;
    using System.Threading.Tasks;
    using ContentReactor.Audio.Service;
    using ContentReactor.Common.Events;
    using ContentReactor.Common.Fakes;
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
    public class GetFunctionTests
    {
        /// <summary>
        /// Given you have an audio api with an audio file that is processed
        /// When you call the get operation
        /// Then it should return the audio blob properties including the transcript.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task WithSuccessReturnsAudio()
        {
            // arrange
            Mock<ILogger> mockLogger = new Mock<ILogger>();
            var mockRequest = Mockers.MockRequest(null);
            var sut = AudioMockers.GetApiFunctionsWithBlobUploaded(
                out FakeBlobRepository fakeBlobRepo);

            fakeBlobRepo.Blobs[0].Properties[Mockers.TranscriptMetadataName] = "faketranscript";

            // act
            var response = await sut.Get(mockRequest.Object, mockLogger.Object, Mockers.DefaultId).ConfigureAwait(false);
            var responseType = (OkObjectResult)response;
            var responseObject = (GetResponse)responseType.Value;

            // assert
            Assert.IsNotNull(responseObject);
            Assert.AreEqual(Mockers.DefaultId, responseObject.Id);
            Assert.AreEqual($"https://fakerepository/audio/fakeuserid/{responseObject.Id}?sasToken=Read", responseObject.AudioUrl.ToString());
            Assert.AreEqual("faketranscript", responseObject.Transcript);
        }

        /// <summary>
        /// Given you have an audio api with an audio file that is not processed
        /// When you call the get operation
        /// Then it should return the audio blob properties with the null transcript.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task WithTranscriptMissingReturnsAudioNote()
        {
            // arrange
            Mock<ILogger> mockLogger = new Mock<ILogger>();
            var mockRequest = Mockers.MockRequest(null);
            var sut = AudioMockers.GetApiFunctionsWithBlobUploaded(
                out FakeBlobRepository fakeBlobRepo);

            // act
            var response = await sut.Get(mockRequest.Object, mockLogger.Object, Mockers.DefaultId).ConfigureAwait(false);
            var responseType = (OkObjectResult)response;
            var responseObject = (GetResponse)responseType.Value;

            // assert
            Assert.IsNotNull(responseObject);
            Assert.AreEqual(Mockers.DefaultId, responseObject.Id);
            Assert.AreEqual($"https://fakerepository/audio/fakeuserid/{responseObject.Id}?sasToken=Read", responseObject.AudioUrl.ToString());
            Assert.IsNull(responseObject.Transcript);
        }

        /// <summary>
        /// Given you have an audio api with no audio files
        /// When you call the GetFunctionAsync method
        /// Then it should return a no content result.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task WithInvalidAudioIdReturnsNull()
        {
            // arrange
            Mock<ILogger> mockLogger = new Mock<ILogger>();
            var mockRequest = Mockers.MockRequest(null);
            var sut = AudioMockers.GetApiFunctionsWithBlobUploaded(
                out FakeBlobRepository fakeBlobRepo);

            fakeBlobRepo.Blobs.Clear();

            // act
            var response = await sut.Get(mockRequest.Object, mockLogger.Object, Mockers.DefaultId).ConfigureAwait(false);
            var responseType = (NotFoundResult)response;

            // assert
            Assert.IsNotNull(responseType);
        }

        /// <summary>
        /// Given you have an audio api with an audio file
        /// When you call the get operation and pass in an invalid user id with the right blob id
        /// Then it should return a null result.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task WithIncorrectUserIdReturnsNull()
        {
            // arrange
            Mock<ILogger> mockLogger = new Mock<ILogger>();
            var mockRequest = Mockers.MockRequest(null);
            var sut = AudioMockers.GetApiFunctionsWithBlobUploaded(
                out FakeBlobRepository fakeBlobRepo);

            fakeBlobRepo.Blobs.Clear();
            fakeBlobRepo.AddFakeBlob(Mockers.AudioContainerName, $"user2id/{Mockers.DefaultId}");

            // act
            var response = await sut.Get(mockRequest.Object, mockLogger.Object, Mockers.DefaultId).ConfigureAwait(false);
            var responseType = (NotFoundResult)response;

            // assert
            Assert.IsNotNull(responseType);
        }

        /// <summary>
        /// Given you have an audio api
        /// When you call the get operation without a user id
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
            var response = await sut.Get(mockRequest.Object, mockLogger.Object, Mockers.DefaultId).ConfigureAwait(false);
            var objectResult = (BadRequestObjectResult)response;
            var addResponse = (dynamic)objectResult.Value;

            // assert
            Assert.AreEqual("Error.", addResponse.error);
        }

        /// <summary>
        /// Given you have an audio api
        /// When you call the get operation
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
            await Assert.ThrowsExceptionAsync<System.Exception>(() => sut.Get(mockRequest.Object, mockLogger.Object, Mockers.DefaultId)).ConfigureAwait(false);

            mockLogger.Verify(moc => moc.Log(LogLevel.Error, It.IsAny<System.Exception>(), "Unhandled Exception."));
        }
    }
}
