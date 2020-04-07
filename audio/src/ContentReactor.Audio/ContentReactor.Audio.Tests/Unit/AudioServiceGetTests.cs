namespace ContentReactor.Audio.Tests.Unit
{
    using System.Threading.Tasks;
    using ContentReactor.Audio.Services;
    using ContentReactor.Common;
    using ContentReactor.Common.Blobs;
    using ContentReactor.Tests.Fakes;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Moq;

    /// <summary>
    /// Contains unit tests for the Audio Service get opreations.
    /// </summary>
    [TestClass]
    public class AudioServiceGetTests
    {
        /// <summary>
        /// Given you have an audio service with an audio file that is processed
        /// When you call the GetAudioNoteAsync method
        /// Then it should return the audio blob properties including the transcript.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task GetAudioNoteReturnsAudio()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            var fullAudioBlob = new Blob("fakeaccount", "audio", "fakeuserid/fakeid");
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
        public async Task GetAudioNoteTranscriptMissing()
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
        public async Task GetAudioNoteInvalidAudioIdReturnsNull()
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
        public async Task GetAudioNoteIncorrectUserIdReturnsNull()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            var fullAudioBlob = new Blob("fakeAccount", "audio", "fakeuserid/fakeblobid");
            fullAudioBlob.Properties[AudioService.TranscriptMetadataName] = "faketranscript";
            fakeBlobRepository.AddFakeBlob(fullAudioBlob);
            var service = new AudioService(fakeBlobRepository, new Mock<IAudioTranscriptionService>().Object, new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.GetAudioNoteAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.IsNull(result);
        }
    }
}
