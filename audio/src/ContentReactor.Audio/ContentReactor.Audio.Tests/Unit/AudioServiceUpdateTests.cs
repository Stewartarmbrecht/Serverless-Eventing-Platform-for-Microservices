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
    /// Contains unit tests for the Audio Service update operations.
    /// </summary>
    [TestClass]
    public class AudioServiceUpdateTests
    {
        /// <summary>
        /// Given you have an audio service with an audio blob
        /// When you call the UpdateAudioTranscriptAsync method
        /// Then it should return the transcript.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task UpdateAudioTranscriptReturnsTranscript()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            fakeBlobRepository.AddFakeBlob(AudioService.AudioBlobContainerName, "fakeuserid/fakeid");
            var mockAudioTranscriptionService = new Mock<IAudioTranscriptionService>();
            mockAudioTranscriptionService
                .Setup(m => m.GetAudioTranscriptFromCognitiveServicesAsync(It.IsAny<Stream>()))
                .ReturnsAsync("transcript");
            var service = new AudioService(fakeBlobRepository, mockAudioTranscriptionService.Object, new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.UpdateAudioTranscriptAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.AreEqual("transcript", result);
        }

        /// <summary>
        /// Given you have an audio service with an audio blob
        /// When you call the UpdateAudioTranscriptAsync method
        /// Then it should update the transcript property of the blob.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task UpdateAudioTranscriptUpdatesTranscriptBlobMetadata()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            fakeBlobRepository.AddFakeBlob(AudioService.AudioBlobContainerName, "fakeuserid/fakeid");
            var mockAudioTranscriptionService = new Mock<IAudioTranscriptionService>();
            mockAudioTranscriptionService
                .Setup(m => m.GetAudioTranscriptFromCognitiveServicesAsync(It.IsAny<Stream>()))
                .ReturnsAsync("transcript");
            var service = new AudioService(fakeBlobRepository, mockAudioTranscriptionService.Object, new Mock<IEventGridPublisherService>().Object);

            // act
            await service.UpdateAudioTranscriptAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.IsTrue(fakeBlobRepository.Blobs.Single().Properties.ContainsKey(AudioService.TranscriptMetadataName));
            Assert.AreEqual("transcript", fakeBlobRepository.Blobs.Single().Properties[AudioService.TranscriptMetadataName].Replace(" with a suffix", string.Empty, StringComparison.Ordinal));
        }

        /// <summary>
        /// Given you have an audio service with an audio blob
        /// When you call the UpdateAudioTranscriptAsync method
        /// Then it should raise the AudioEvents.AudioTranscriptUpdated event.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task UpdateAudioTranscriptPublishesAudioTranscriptUpdatedEventToEventGrid()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            fakeBlobRepository.AddFakeBlob(AudioService.AudioBlobContainerName, "fakeuserid/fakeid");
            var mockAudioTranscriptionService = new Mock<IAudioTranscriptionService>();
            mockAudioTranscriptionService
                .Setup(m => m.GetAudioTranscriptFromCognitiveServicesAsync(It.IsAny<Stream>()))
                .ReturnsAsync("transcript");
            var mockEventGridPublisherService = new Mock<IEventGridPublisherService>();
            var service = new AudioService(fakeBlobRepository, mockAudioTranscriptionService.Object, mockEventGridPublisherService.Object);

            // act
            await service.UpdateAudioTranscriptAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            mockEventGridPublisherService.Verify(
                m => m.PostEventGridEventAsync(
                    AudioEvents.AudioTranscriptUpdated,
                    "fakeuserid/fakeid",
                    It.Is<AudioTranscriptUpdatedEventData>(d => d.TranscriptPreview.Replace(" with a suffix", string.Empty, StringComparison.Ordinal) == "transcript")),
                Times.Once);
        }

        /// <summary>
        /// Given you have an audio service
        /// When you call the UpdateAudioTranscriptAsync method with an invalid audio blob id
        /// Then it should return null.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task UpdateAudioTranscriptInvalidAudioIdAudioNotFound()
        {
            // arrange
            var service = new AudioService(new FakeBlobRepository(), new Mock<IAudioTranscriptionService>().Object, new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.UpdateAudioTranscriptAsync("invalidaudioid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.IsNull(result);
        }

        /// <summary>
        /// Given you have an audio service with a blob
        /// When you call the UpdateAudioTranscriptAsync method with an invalid user id but the correct blob id
        /// Then it should return null.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task UpdateAudioTranscriptIncorrectUserIdReturnsTranscript()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            fakeBlobRepository.AddFakeBlob(AudioService.AudioBlobContainerName, "fakeuserid2/fakeid");
            var mockAudioTranscriptionService = new Mock<IAudioTranscriptionService>();
            mockAudioTranscriptionService
                .Setup(m => m.GetAudioTranscriptFromCognitiveServicesAsync(It.IsAny<Stream>()))
                .ReturnsAsync("transcript");
            var service = new AudioService(fakeBlobRepository, mockAudioTranscriptionService.Object, new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.UpdateAudioTranscriptAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.IsNull(result);
        }
    }
}
