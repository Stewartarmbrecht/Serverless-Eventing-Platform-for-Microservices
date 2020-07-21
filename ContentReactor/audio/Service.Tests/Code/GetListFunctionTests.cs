namespace ContentReactor.Audio.Service.Tests.Unit
{
    using System.Threading.Tasks;
    using ContentReactor.Audio.Service;
    using ContentReactor.Common.Fakes;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Extensions.Logging;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Moq;

    /// <summary>
    /// Contains unit tests for the Audio Service list operations.
    /// </summary>
    [TestClass]
    public class GetListFunctionTests
    {
        /// <summary>
        /// Given you have an audio api with 2 blobs for a single user
        /// When you call the get list opreation with the correct user id as the prefix
        /// Then it should return both blobs.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task WithSuccessReturnsSummaries()
        {
            // arrange
            Mock<ILogger> mockLogger = new Mock<ILogger>();
            var mockRequest = Mockers.MockRequest(null);
            var sut = AudioMockers.GetApiFunctionsWithBlobUploaded(
                out FakeBlobRepository fakeBlobRepo);

            fakeBlobRepo.AddFakeBlob(Mockers.AudioContainerName, $"{Mockers.DefaultUserId}/newblobname");
            fakeBlobRepo.Blobs[0].Properties[Mockers.TranscriptMetadataName] = "faketranscript";

            // act
            var response = await sut.GetList(mockRequest.Object, mockLogger.Object).ConfigureAwait(false);
            var responseType = (ObjectResult)response;
            var responseObject = (GetListResponse)responseType.Value;

            // assert
            Assert.IsNotNull(responseObject);
            Assert.AreEqual(2, responseObject.Count);
            Assert.AreEqual(Mockers.DefaultId, responseObject[0].Id);
            Assert.AreEqual("faketranscript", responseObject[0].Preview);
        }

        /// <summary>
        /// Given you have an audio api with 2 blobs for 2 users user
        /// When you call the get list operation with the first user id as the prefix
        /// Then it should return only that users blob.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task WithAnotherUserIdDoesNotReturnSummaries()
        {
            // arrange
            Mock<ILogger> mockLogger = new Mock<ILogger>();
            var mockRequest = Mockers.MockRequest(null);
            var sut = AudioMockers.GetApiFunctionsWithBlobUploaded(
                out FakeBlobRepository fakeBlobRepo);

            fakeBlobRepo.AddFakeBlob(Mockers.AudioContainerName, "newblobname");

            // act
            var response = await sut.GetList(mockRequest.Object, mockLogger.Object).ConfigureAwait(false);
            var responseType = (ObjectResult)response;
            var responseObject = (GetListResponse)responseType.Value;

            // assert
            Assert.IsNotNull(responseObject);
            Assert.AreEqual(1, responseObject.Count);
        }
    }
}
