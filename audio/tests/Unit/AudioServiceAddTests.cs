namespace ContentReactor.Audio.Tests.Unit
{
    using System;
    using System.Diagnostics.CodeAnalysis;
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
    /// Contains unit tests for the Audio Service add opertions.
    /// </summary>
    [TestClass]
    public class AudioServiceAddTests
    {
        /// <summary>
        /// Given you have an audio service
        /// When you call the BeginAddAudioNote method
        /// Then it should return the id of the new blob and the url to upload the file to.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [SuppressMessage("StyleCop.CSharp.SpacingRules", "SA1008:OpeningParenthesisMustBeSpacedCorrectly", Justification = "Reviewed.")]
        [TestMethod]
        public async Task BeginAddAudioNoteReturnsIdAndUrl()
        {
            // arrange
            var service = new AudioService(new FakeBlobRepository(), new Mock<IAudioTranscriptionService>().Object, new Mock<IEventGridPublisherService>().Object);

            // act
            var (id, url) = await service.BeginAddAudioNote("fakeuserid").ConfigureAwait(false);

            // assert
            Assert.IsNotNull(id);
            Assert.AreEqual($"https://fakerepository/audio/fakeuserid/{id}?sasToken=Write", url);
        }

        /// <summary>
        /// Given you have an audio service with an audio file started for upload
        /// When you call the CompleteAddAudioNoteAsync method
        /// Then it should return a CompleteAddAudioNoteResult.Success enum value.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task CompleteAddAudioNoteReturnsSuccess()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            fakeBlobRepository.AddFakeBlob(AudioService.AudioBlobContainerName, "fakeuserid/fakeid");
            var service = new AudioService(fakeBlobRepository, new Mock<IAudioTranscriptionService>().Object, new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.CompleteAddAudioNoteAsync("fakeid", "fakeuserid", "fakecategory").ConfigureAwait(false);

            // assert
            Assert.AreEqual(CompleteAddAudioNoteResult.Success, result);
        }

        /// <summary>
        /// Given you have an audio service with an audio file started for upload
        /// When you call the CompleteAddAudioNoteAsync method
        /// Then it should update the cateogery and user id properties of the blob.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task CompleteAddAudioNoteUpdatesBlobMetadata()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            fakeBlobRepository.AddFakeBlob(AudioService.AudioBlobContainerName, "fakeuserid/fakeid");
            var service = new AudioService(fakeBlobRepository, new Mock<IAudioTranscriptionService>().Object, new Mock<IEventGridPublisherService>().Object);

            // act
            await service.CompleteAddAudioNoteAsync("fakeid", "fakeuserid", "fakecategory").ConfigureAwait(false);

            // assert
            Assert.AreEqual("fakecategory", fakeBlobRepository.Blobs.Single().Properties[AudioService.CategoryIdMetadataName]);
            Assert.AreEqual("fakeuserid", fakeBlobRepository.Blobs.Single().Properties[AudioService.UserIdMetadataName]);
        }

        /// <summary>
        /// Given you have an audio service with an audio file started for upload
        /// When you call the CompleteAddAudioNoteAsync method
        /// Then it should raise an AudioCreated event.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task CompleteAddAudioNotePublishesAudioCreatedEventToEventGrid()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            fakeBlobRepository.AddFakeBlob(AudioService.AudioBlobContainerName, "fakeuserid/fakeid");
            var mockEventGridPublisherService = new Mock<IEventGridPublisherService>();
            var service = new AudioService(fakeBlobRepository, new Mock<IAudioTranscriptionService>().Object, mockEventGridPublisherService.Object);

            // act
            await service.CompleteAddAudioNoteAsync("fakeid", "fakeuserid", "fakecategory").ConfigureAwait(false);

            // assert
            mockEventGridPublisherService.Verify(
                m => m.PostEventGridEventAsync(
                    AudioEvents.AudioCreated,
                    "fakeuserid/fakeid",
                    It.Is<AudioCreatedEventData>(d => d.Category == "fakecategory")),
                Times.Once);
        }

        /// <summary>
        /// Given you have an audio service with no audio files uploaded
        /// When you call the CompleteAddAudioNoteAsync method
        /// Then it should return an CompleteAddAudioNoteResult.AudioNotUploaded enum value.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task CompleteAddAudioNoteReturnsAudioNotUploaded()
        {
            // arrange
            var service = new AudioService(new FakeBlobRepository(), new Mock<IAudioTranscriptionService>().Object, new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.CompleteAddAudioNoteAsync("fakeid", "fakeuserid", "fakecategory").ConfigureAwait(false);

            // assert
            Assert.AreEqual(CompleteAddAudioNoteResult.AudioNotUploaded, result);
        }

        /// <summary>
        /// Given you have an audio service with an audio file that is already processed
        /// When you call the CompleteAddAudioNoteAsync method
        /// Then it should return an CompleteAddAudioNoteResult.AudioAlreadyCreated enum value.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task CompleteAddAudioNoteReturnsAudioAlreadyCreated()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            var blob = new Blob("fakeaccountname", "audio", "fakeuserid/fakeid");
            blob.Properties.Add(AudioService.CategoryIdMetadataName, "fakecategory");
            blob.Properties.Add(AudioService.UserIdMetadataName, "fakeuserid");
            fakeBlobRepository.AddFakeBlob(blob);
            var mockEventGridPublisherService = new Mock<IEventGridPublisherService>();
            var service = new AudioService(fakeBlobRepository, new Mock<IAudioTranscriptionService>().Object, mockEventGridPublisherService.Object);

            // act
            var result = await service.CompleteAddAudioNoteAsync("fakeid", "fakeuserid", "fakecategory").ConfigureAwait(false);

            // assert
            Assert.AreEqual(CompleteAddAudioNoteResult.AudioAlreadyCreated, result);
        }

        /// <summary>
        /// Given you have an audio service with an audio file that is not processed
        /// When you call the CompleteAddAudioNoteAsync method with the wrong user id
        /// Then it should return an CompleteAddAudioNoteResult.AudioNotUploaded enum value.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task CompleteAddAudioNoteIncorrectUserIdReturnsAudioNotUploaded()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            fakeBlobRepository.AddFakeBlob(AudioService.AudioBlobContainerName, "fakeuserid2/fakeid");
            var service = new AudioService(fakeBlobRepository, new Mock<IAudioTranscriptionService>().Object, new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.CompleteAddAudioNoteAsync("fakeid", "fakeuserid", "fakecategory").ConfigureAwait(false);

            // assert
            Assert.AreEqual(CompleteAddAudioNoteResult.AudioNotUploaded, result);
        }
    }
}
