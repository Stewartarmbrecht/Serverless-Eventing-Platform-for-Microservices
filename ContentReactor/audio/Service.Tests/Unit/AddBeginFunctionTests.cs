namespace ContentReactor.Audio.Service.Tests.Unit
{
    using System.Linq;
    using System.Threading.Tasks;
    using ContentReactor.Audio.Service;
    using ContentReactor.Common.Events;
    using ContentReactor.Common.Events.Audio;
    using ContentReactor.Common.Fakes;
    using Microsoft.AspNetCore.Http;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Extensions.Logging;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Moq;

    /// <summary>
    /// Contains unit tests for the Audio Service add opertions.
    /// </summary>
    [TestClass]
    public class AddBeginFunctionTests
    {
        /// <summary>
        /// Given you have an audio service
        /// When you call the BeginAddAudioNote method
        /// Then it should return the id of the new blob and the url to upload the file to.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task WithSuccessReturnsIdAndUrl()
        {
            // arrange
            var mockUserAuth = Mockers.MockUserAuth();
            var fakeRepository = new FakeBlobRepository();
            Mock<HttpRequest> mockRequest = Mockers.MockRequest(null);
            Mock<ILogger> mockLogger = new Mock<ILogger>();

            var sut = new Functions(
                mockUserAuth.Object,
                fakeRepository);

            // act
            var response = await sut.AddBegin(mockRequest.Object, mockLogger.Object).ConfigureAwait(false);
            var objectResult = (OkObjectResult)response;
            var addResponse = (AddBeginResponse)objectResult.Value;

            // assert
            Assert.IsNotNull(addResponse.Id);
            Assert.IsNotNull(addResponse.UploadUrl);
            Assert.AreEqual($"https://fakerepository/audio/fakeuserid/{addResponse.Id}?sasToken=Write", addResponse.UploadUrl.ToString());
        }

        /// <summary>
        /// Given you have an audio api with an audio file started for upload
        /// When you call the operation to complete the add
        /// Then it should return a 204 NoContentResult.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task WithMissingUserIdReturnsBadRequest()
        {
            // arrange
            var mockUserAuth = Mockers.MockUserAuth();
            string userId;
            IActionResult actionResult = new BadRequestObjectResult(new { error = "Error." });
            mockUserAuth.Setup(m => m.GetUserIdAsync(It.IsAny<HttpRequest>(), out userId, out actionResult))
                .Returns(Task.FromResult(false));
            var fakeRepository = new FakeBlobRepository();
            Mock<HttpRequest> mockRequest = Mockers.MockRequest(null);
            Mock<ILogger> mockLogger = new Mock<ILogger>();

            var sut = new Functions(
                mockUserAuth.Object,
                fakeRepository);

            // act
            var response = await sut.AddBegin(mockRequest.Object, mockLogger.Object).ConfigureAwait(false);
            var objectResult = (BadRequestObjectResult)response;
            var addResponse = (dynamic)objectResult.Value;

            // assert
            Assert.AreEqual("Error.", addResponse.error);
        }

        /// <summary>
        /// Given you have an audio api
        /// When you call the begin add operation
        /// And a sub-component throws and exception
        /// Then it should log the exception and throw it.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Globalization", "CA1303", Justification="Reviewed")]
        [TestMethod]
        public async Task WithThrownExceptionThrowsException()
        {
            // arrange
            var mockUserAuth = Mockers.MockUserAuth();
            string userId;
            IActionResult actionResult = new BadRequestObjectResult(new { error = "Error." });
            System.Exception ex = new System.Exception("My error.");
            mockUserAuth.Setup(m => m.GetUserIdAsync(It.IsAny<HttpRequest>(), out userId, out actionResult))
                .ThrowsAsync(ex);
            var fakeRepository = new FakeBlobRepository();
            Mock<HttpRequest> mockRequest = Mockers.MockRequest(null);
            Mock<AbstractLogger> mockLogger = new Mock<AbstractLogger>();

            var sut = new Functions(
                mockUserAuth.Object,
                fakeRepository);

            // act
            await Assert.ThrowsExceptionAsync<System.Exception>(() => sut.AddBegin(mockRequest.Object, mockLogger.Object)).ConfigureAwait(false);

            mockLogger.Verify(moc => moc.Log(LogLevel.Error, It.IsAny<System.Exception>(), "Unhandled Exception."));
        }
    }
}
