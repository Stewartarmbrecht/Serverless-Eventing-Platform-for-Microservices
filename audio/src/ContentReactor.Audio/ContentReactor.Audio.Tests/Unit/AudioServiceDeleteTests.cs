namespace ContentReactor.Audio.Tests.Unit
{
    using System;
    using System.IO;
    using System.Linq;
    using System.Threading.Tasks;
    using ContentReactor.Audio.Services;
    using ContentReactor.Audio.Services.Models.Results;
    using ContentReactor.Common;
    using ContentReactor.Common.Blobs;
    using ContentReactor.Common.EventSchemas.Audio;
    using ContentReactor.Common.EventTypes;
    using ContentReactor.Tests.Fakes;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Moq;

    /// <summary>
    /// Contains unit tests for the Audio Service delete operation.
    /// </summary>
    [TestClass]
    public class AudioServiceDeleteTests
    {
        /// <summary>
        /// Given you have an audio service with a blob
        /// When you call the DeleteAudioNoteAsync method
        /// Then it should delete the blob from the repository.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task DeleteAudioNoteDeletesBlob()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            fakeBlobRepository.AddFakeBlob(AudioService.AudioBlobContainerName, "fakeuserid/fakeid");
            var service = new AudioService(fakeBlobRepository, new Mock<IAudioTranscriptionService>().Object, new Mock<IEventGridPublisherService>().Object);

            // act
            await service.DeleteAudioNoteAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.IsNull(fakeBlobRepository.Blobs.FirstOrDefault());
        }

        /// <summary>
        /// Given you have an audio service with a blob
        /// When you call the DeleteAudioNoteAsync method
        /// Then it should raise the AudioDeleted event.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task DeleteAudioNotePublishesAudioDeletedEventToEventGrid()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            fakeBlobRepository.AddFakeBlob(AudioService.AudioBlobContainerName, "fakeuserid/fakeid");
            var mockEventGridPublisherService = new Mock<IEventGridPublisherService>();
            var service = new AudioService(fakeBlobRepository, new Mock<IAudioTranscriptionService>().Object, mockEventGridPublisherService.Object);

            // act
            await service.DeleteAudioNoteAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            mockEventGridPublisherService.Verify(
                m => m.PostEventGridEventAsync(
                    AudioEvents.AudioDeleted,
                    "fakeuserid/fakeid",
                    It.IsAny<AudioDeletedEventData>()),
                Times.Once);
        }

        /// <summary>
        /// Given you have an audio service with no blobs
        /// When you call the DeleteAudioNoteAsync method
        /// Then it should not throw an exception.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task DeleteAudioNoteInvalidAudioIdAudioNotFound()
        {
            // arrange
            var service = new AudioService(new FakeBlobRepository(), new Mock<IAudioTranscriptionService>().Object, new Mock<IEventGridPublisherService>().Object);

            // act
            await service.DeleteAudioNoteAsync("invalidaudioid", "fakeuserid").ConfigureAwait(false);

            // assert
            // no exception thrown
        }

        /// <summary>
        /// Given you have an audio service with a blob
        /// When you call the DeleteAudioNoteAsync method with the wrong user id
        /// Then it should execute, do nothing, and not raise an exception.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task DeleteAudioNoteIncorrectUserIdAudioNotFound()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            fakeBlobRepository.AddFakeBlob(AudioService.AudioBlobContainerName, "fakeuserid/fakeid");
            var service = new AudioService(fakeBlobRepository, new Mock<IAudioTranscriptionService>().Object, new Mock<IEventGridPublisherService>().Object);

            // act
            await service.DeleteAudioNoteAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            // no exception thrown
        }
    }
}
