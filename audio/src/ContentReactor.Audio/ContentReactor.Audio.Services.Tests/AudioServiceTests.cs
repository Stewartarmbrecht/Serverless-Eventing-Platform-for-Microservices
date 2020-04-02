namespace ContentReactor.Audio.Services.Tests
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
    /// Contains unit tests foer the Audio Service class.
    /// </summary>
    [TestClass]
    public class AudioServiceTests
    {
        #region BeginAddAudioNote Tests
        /// <summary>
        /// Given you have an audio service
        /// When you call the BeginAddAudioNote method
        /// Then it should return the id of the new blob and the url to upload the file to.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task BeginAddAudioNote_ReturnsIdAndUrl()
        {
            // arrange
            var service = new AudioService(new FakeBlobRepository(), new Mock<IAudioTranscriptionService>().Object, new Mock<IEventGridPublisherService>().Object);

            // act
            var (id, url) = await service.BeginAddAudioNote("fakeuserid").ConfigureAwait(false);

            // assert
            Assert.IsNotNull(id);
            Assert.AreEqual($"https://fakerepository/audio/fakeuserid/{id}?sasToken=Write", url);
        }
        #endregion

        #region CompleteAddAudioNote Tests
        /// <summary>
        /// Given you have an audio service with an audio file started for upload
        /// When you call the CompleteAddAudioNoteAsync method
        /// Then it should return a CompleteAddAudioNoteResult.Success enum value.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task CompleteAddAudioNote_ReturnsSuccess()
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
        public async Task CompleteAddAudioNote_UpdatesBlobMetadata()
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
        public async Task CompleteAddAudioNote_PublishesAudioCreatedEventToEventGrid()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            fakeBlobRepository.AddFakeBlob(AudioService.AudioBlobContainerName, "fakeuserid/fakeid");
            var mockEventGridPublisherService = new Mock<IEventGridPublisherService>();
            var service = new AudioService(fakeBlobRepository, new Mock<IAudioTranscriptionService>().Object, mockEventGridPublisherService.Object);

            // act
            await service.CompleteAddAudioNoteAsync("fakeid", "fakeuserid", "fakecategory").ConfigureAwait(false);

            // assert
            mockEventGridPublisherService.Verify(m =>
                m.PostEventGridEventAsync(
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
        public async Task CompleteAddAudioNote_ReturnsAudioNotUploaded()
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
        public async Task CompleteAddAudioNote_ReturnsAudioAlreadyCreated()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            var blob = new Blob("fakeaccountname","audio","fakeuserid/fakeid");
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
        public async Task CompleteAddAudioNote_IncorrectUserId_ReturnsAudioNotUploaded()
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
        #endregion

        #region GetAudioNote Tests
        /// <summary>
        /// Given you have an audio service with an audio file that is processed
        /// When you call the GetAudioNoteAsync method
        /// Then it should return the audio blob properties including the transcript.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task GetAudioNote_ReturnsAudio()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            var fullAudioBlob = new Blob("fakeaccount","audio","fakeuserid/fakeid");
            fullAudioBlob.Properties[AudioService.TranscriptMetadataName] = "faketranscript";
            fakeBlobRepository.AddFakeBlob(fullAudioBlob);
            var service = new AudioService(fakeBlobRepository, new Mock<IAudioTranscriptionService>().Object, new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.GetAudioNoteAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.AreEqual("https://fakerepository/audio/fakeuserid/fakeid?sasToken=Read", result.AudioUrl.OriginalString);
            Assert.AreEqual("faketranscript", result.Transcript);
        }

        /// <summary>
        /// Given you have an audio service with an audio file that is not processed
        /// When you call the GetAudioNoteAsync method
        /// Then it should return the audio blob properties with the null transcript.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task GetAudioNote_TranscriptMissing()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            fakeBlobRepository.AddFakeBlob(AudioService.AudioBlobContainerName, "fakeuserid/fakeid");
            var service = new AudioService(fakeBlobRepository, new Mock<IAudioTranscriptionService>().Object, new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.GetAudioNoteAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.AreEqual("https://fakerepository/audio/fakeuserid/fakeid?sasToken=Read", result.AudioUrl.OriginalString);
            Assert.IsNull(result.Transcript);
        }

        /// <summary>
        /// Given you have an audio service with no audio files
        /// When you call the GetAudioNoteAsync method
        /// Then it should return a null result.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task GetAudioNote_InvalidAudioId_ReturnsNull()
        {
            // arrange
            var service = new AudioService(new FakeBlobRepository(), new Mock<IAudioTranscriptionService>().Object, new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.GetAudioNoteAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.IsNull(result);
        }

        /// <summary>
        /// Given you have an audio service with an audio file
        /// When you call the GetAudioNoteAsync method and pass in an invalid user id with the right blob id
        /// Then it should return a null result.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task GetAudioNote_IncorrectUserId_ReturnsNull()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            var fullAudioBlob = new Blob("fakeAccount","audio","fakeuserid/fakeblobid");
            fullAudioBlob.Properties[AudioService.TranscriptMetadataName] = "faketranscript";
            fakeBlobRepository.AddFakeBlob(fullAudioBlob);
            var service = new AudioService(fakeBlobRepository, new Mock<IAudioTranscriptionService>().Object, new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.GetAudioNoteAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.IsNull(result);
        }
        #endregion

        #region ListAudioNotes Tests
        /// <summary>
        /// Given you have an audio service with 2 blobs for a single user
        /// When you call the ListAudioNotesAsync method with the correct user id as the prefix
        /// Then it should return both blobs.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task ListAudioNotes_ReturnsSummaries()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            var blob1 = new Blob("fakeAccount","audio","fakeuserid/fakeid1");
            blob1.Properties.Add(AudioService.TranscriptMetadataName, "transcript1");
            fakeBlobRepository.AddFakeBlob(blob1);
            var blob2 = new Blob("fakeAccount","audio","fakeuserid/fakeid2");
            blob2.Properties.Add(AudioService.TranscriptMetadataName, "transcript2");
            fakeBlobRepository.AddFakeBlob(blob2);
            var service = new AudioService(fakeBlobRepository, new Mock<IAudioTranscriptionService>().Object, new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.ListAudioNotesAsync("fakeuserid").ConfigureAwait(false);

            // assert
            Assert.AreEqual(2, result.Count);
            Assert.IsTrue(result.Any(r => r.Id == "fakeid1" && r.Preview == "transcript1"));
            Assert.IsTrue(result.Any(r => r.Id == "fakeid2" && r.Preview == "transcript2"));
        }

        /// <summary>
        /// Given you have an audio service with 2 blobs for 2 users user
        /// When you call the ListAudioNotesAsync method with the first user id as the prefix
        /// Then it should return only that users blob.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task ListAudioNotes_DoesNotReturnsSummariesForAnotherUser()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            var blob1 = new Blob("fakeAccount","audio","fakeuserid1/fakeblobid1");
            blob1.Properties.Add(AudioService.TranscriptMetadataName, "transcript1");
            fakeBlobRepository.AddFakeBlob(blob1);
            var blob2 = new Blob("fakeAccount","audio","fakeuserid2/fakeblobid2");
            blob2.Properties.Add(AudioService.TranscriptMetadataName, "transcript2");
            fakeBlobRepository.AddFakeBlob(blob2);
            var service = new AudioService(fakeBlobRepository, new Mock<IAudioTranscriptionService>().Object, new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.ListAudioNotesAsync("fakeuserid1").ConfigureAwait(false);

            // assert
            Assert.IsTrue(result.Count() == 1);
            Assert.AreEqual("fakeblobid1", result.Single().Id);
            Assert.AreEqual("transcript1", result.Single().Preview);
        }
        #endregion

        #region DeleteAudioNote Tests
        /// <summary>
        /// Given you have an audio service with a blob
        /// When you call the DeleteAudioNoteAsync method
        /// Then it should delete the blob from the repository.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task DeleteAudioNote_DeletesBlob()
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
        public async Task DeleteAudioNote_PublishesAudioDeletedEventToEventGrid()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            fakeBlobRepository.AddFakeBlob(AudioService.AudioBlobContainerName, "fakeuserid/fakeid");
            var mockEventGridPublisherService = new Mock<IEventGridPublisherService>();
            var service = new AudioService(fakeBlobRepository, new Mock<IAudioTranscriptionService>().Object, mockEventGridPublisherService.Object);

            // act
            await service.DeleteAudioNoteAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            mockEventGridPublisherService.Verify(m =>
                m.PostEventGridEventAsync(
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
        public async Task DeleteAudioNote_InvalidAudioId_AudioNotFound()
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
        public async Task DeleteAudioNote_IncorrectUserId_AudioNotFound()
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
        #endregion

        #region UpdateAudioTranscript Tests
        /// <summary>
        /// Given you have an audio service with an audio blob
        /// When you call the UpdateAudioTranscriptAsync method
        /// Then it should return the transcript.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task UpdateAudioTranscript_ReturnsTranscript()
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
        public async Task UpdateAudioTranscript_UpdatesTranscriptBlobMetadata()
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
            Assert.AreEqual("transcript",fakeBlobRepository.Blobs.Single().Properties[AudioService.TranscriptMetadataName].Replace(" with a suffix",""));
        }

        /// <summary>
        /// Given you have an audio service with an audio blob
        /// When you call the UpdateAudioTranscriptAsync method
        /// Then it should raise the AudioEvents.AudioTranscriptUpdated event.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task UpdateAudioTranscript_PublishesAudioTranscriptUpdatedEventToEventGrid()
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
            mockEventGridPublisherService.Verify(m =>
                m.PostEventGridEventAsync(
                    AudioEvents.AudioTranscriptUpdated,
                    "fakeuserid/fakeid",
                    It.Is<AudioTranscriptUpdatedEventData>(d => d.TranscriptPreview.Replace(" with a suffix", "") == "transcript")),
                Times.Once);
        }

        /// <summary>
        /// Given you have an audio service
        /// When you call the UpdateAudioTranscriptAsync method with an invalid audio blob id
        /// Then it should return null.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task UpdateAudioTranscript_InvalidAudioId_AudioNotFound()
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
        public async Task UpdateAudioTranscript_IncorrectUserId_ReturnsTranscript()
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
        #endregion
    }
}
