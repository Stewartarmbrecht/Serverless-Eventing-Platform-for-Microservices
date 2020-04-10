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
    /// Contains unit tests for the Audio Service list operations.
    /// </summary>
    [TestClass]
    public class AudioServiceListTests
    {
        /// <summary>
        /// Given you have an audio service with 2 blobs for a single user
        /// When you call the ListAudioNotesAsync method with the correct user id as the prefix
        /// Then it should return both blobs.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task ListAudioNotesReturnsSummaries()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            var blob1 = new Blob("fakeAccount", "audio", "fakeuserid/fakeid1");
            blob1.Properties.Add(AudioService.TranscriptMetadataName, "transcript1");
            fakeBlobRepository.AddFakeBlob(blob1);
            var blob2 = new Blob("fakeAccount", "audio", "fakeuserid/fakeid2");
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
        public async Task ListAudioNotesDoesNotReturnsSummariesForAnotherUser()
        {
            // arrange
            var fakeBlobRepository = new FakeBlobRepository();
            var blob1 = new Blob("fakeAccount", "audio", "fakeuserid1/fakeblobid1");
            blob1.Properties.Add(AudioService.TranscriptMetadataName, "transcript1");
            fakeBlobRepository.AddFakeBlob(blob1);
            var blob2 = new Blob("fakeAccount", "audio", "fakeuserid2/fakeblobid2");
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
    }
}
