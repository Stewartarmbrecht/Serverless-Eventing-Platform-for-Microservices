namespace ContentReactor.Audio.Services.Tests
{
    using System;
    using System.Collections.Generic;
    using System.Threading.Tasks;
    using System.Net.Http;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Newtonsoft.Json;
    using ContentReactor.Audio.Services.Models.Responses;

    /// <summary>
    /// Contains end to end tests for the Audio API.
    /// </summary>
    [TestClass]
    [TestCategory("E2E")]
    public class AudioApiTests
    {
        private readonly string baseUrl = "http://localhost:7073/api/audio";
        private readonly string defaultUserId = "developer@edentest.com";
        private static readonly HttpClient HTTP_CLIENT = new HttpClient();

        /// <summary>
        /// Given you have an audio note
        /// When you add the audio note through the api
        /// Then you should be able to retrieve a url to download the note
        /// And the note should have the category that you specified when completing the upload
        /// And the note should have a transcription
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task AddAudioWithSuccess()
        {
            // Get the url to upload a new audio file.
            (string blobId, string blobUploadUrl) = await BeginAddAudio().ConfigureAwait(false);

            // Upload the audio file to the storage service.
            await UploadFile(blobUploadUrl).ConfigureAwait(false);

            // Complete the add of the new audio file with the audio service
            await EndAddAudio(blobId).ConfigureAwait(false);

            // Get the new audio file and validate its properties
            Models.Responses.AudioNoteDetails audioNoteDetail = await GetAudioDetail(blobId).ConfigureAwait(false);

            // Check the blob to verify it is transcribed with in 10 seconds.
            await GetAudioTranscript(audioNoteDetail).ConfigureAwait(false);
        }

        /// <summary>
        /// Given you have an audio note that you have added
        /// When you delete the audio note
        /// Then you should receive a complete message
        /// And the get operation should no longer return the note
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task DeleteAudioWithSuccess()
        {
            // Add an audio note.
            AudioNoteDetails audioNoteDetail = await AddAudioNote().ConfigureAwait(false);

            // Delete the audio note.
            await DeleteAudio(audioNoteDetail).ConfigureAwait(false);

            // Get the deleted audio file and validate not found result.
            var missing = await GetMissingAudioDetail(audioNoteDetail.Id).ConfigureAwait(false);

            Assert.IsTrue(missing);
        }

        /// <summary>
        /// Given you added multiple audio notes for multiple users
        /// When you call the list audio note operation for a single user
        /// Then you should get a list of all audio notes for that user
        /// And you should not get any of the audio notes for another user.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task ListAudioWithSuccess()
        {
            string firstUserId = Guid.NewGuid().ToString();
            string secondUserId = Guid.NewGuid().ToString();
            // Add an audio notes for default user and second user.
            await AddAudioNote(firstUserId).ConfigureAwait(false);
            await AddAudioNote(firstUserId).ConfigureAwait(false);
            await AddAudioNote(secondUserId).ConfigureAwait(false);
            await AddAudioNote(secondUserId).ConfigureAwait(false);

            // Delete the audio note.
            var audioNotes = await ListAudioDetail(secondUserId).ConfigureAwait(false);

            // Validate result set.
            Assert.AreEqual(2, audioNotes.Count);
            Assert.IsNotNull(audioNotes[0].Id);
            Assert.IsNotNull(audioNotes[1].Id);
        }

        private async Task<AudioNoteDetails> AddAudioNote(string userId = null)
        {
            (string blobId, string blobUploadUrl) = await BeginAddAudio(userId).ConfigureAwait(false);

            // Upload the audio file to the storage service.
            await UploadFile(blobUploadUrl).ConfigureAwait(false);

            // Complete the add of the new audio file with the audio service
            await EndAddAudio(blobId, userId).ConfigureAwait(false);

            // Get the new audio file and validate its properties
            Models.Responses.AudioNoteDetails audioNoteDetail = await GetAudioDetail(blobId, userId).ConfigureAwait(false);
            return audioNoteDetail;
        }

        private async Task<(string blobId, string blobUploadUrl)> BeginAddAudio(string userId = null)
        {
            userId ??= this.defaultUserId;
            Uri postUri = new Uri($"{this.baseUrl}?userId={userId}");
            var beginAddResponse = await HTTP_CLIENT.PostAsync(postUri, null).ConfigureAwait(false);
            var beginAddResponseContent = await beginAddResponse.Content.ReadAsStringAsync().ConfigureAwait(false);
            dynamic beginAddResult = JsonConvert.DeserializeObject(beginAddResponseContent);
            var blobId = (string)beginAddResult.id;
            var blobUploadUrl = (string)beginAddResult.url;
            Assert.IsNotNull(blobId);
            Assert.IsNotNull(blobUploadUrl);
            return (blobId, blobUploadUrl);
        }

        private async Task<AudioNoteDetails> GetAudioDetail(string blobId, string userId = null)
        {
            userId ??= this.defaultUserId;
            Uri getUrl = new Uri($"{this.baseUrl}/{blobId}?userId={userId}");
            var getResponse = await HTTP_CLIENT.GetAsync(getUrl).ConfigureAwait(false);
            var getResponseContent = await getResponse.Content.ReadAsStringAsync().ConfigureAwait(false);
            Models.Responses.AudioNoteDetails audioNoteDetail =
                JsonConvert.DeserializeObject<Models.Responses.AudioNoteDetails>(getResponseContent);
            Assert.AreEqual(blobId, audioNoteDetail.Id);
            string downloadUrlEnd = $"audioblob.blob.core.windows.net/audio/{userId}/{blobId}";
            Assert.IsTrue(audioNoteDetail.AudioUrl.ToString().Contains(downloadUrlEnd));
            return audioNoteDetail;
        }

        private async Task<AudioNoteSummaryCollection> ListAudioDetail(string userId = null)
        {
            userId ??= this.defaultUserId;
            Uri getUrl = new Uri($"{this.baseUrl}?userId={userId}");
            var getResponse = await HTTP_CLIENT.GetAsync(getUrl).ConfigureAwait(false);
            var getResponseContent = await getResponse.Content.ReadAsStringAsync().ConfigureAwait(false);
            AudioNoteSummaryCollection audioNotes = JsonConvert.DeserializeObject<AudioNoteSummaryCollection>(getResponseContent);
            return audioNotes;
        }

        private async Task<bool> GetMissingAudioDetail(string blobId, string userId = null)
        {
            userId ??= this.defaultUserId;
            Uri getUrl = new Uri($"{this.baseUrl}/{blobId}?userId={userId}");
            var getResponse = await HTTP_CLIENT.GetAsync(getUrl).ConfigureAwait(false);
            return getResponse.StatusCode == System.Net.HttpStatusCode.NotFound;
        }

        private async Task EndAddAudio(string blobId, string userId = null)
        {
            userId ??= this.defaultUserId;
            Uri endAddUrl = new Uri($"{this.baseUrl}/{blobId}?userId={userId}");
            var endAddContent = new StringContent("{\"categoryId\":\"My Test\"}");
            var endAddResponse = await HTTP_CLIENT.PostAsync(endAddUrl, endAddContent).ConfigureAwait(false);
            Assert.IsTrue(endAddResponse.StatusCode == System.Net.HttpStatusCode.NoContent);
            return;
        }

        private static async Task UploadFile(string blobUploadUrl)
        {
            var audioFile = await System.IO.File.ReadAllBytesAsync("no-thats-not-gonna-do-it.wav").ConfigureAwait(false);
            Assert.IsNotNull(audioFile);
            var uploadFile = new ByteArrayContent(audioFile);
            var uploadRequest = new HttpRequestMessage()
            {
                Method = HttpMethod.Put,
                RequestUri = new Uri(blobUploadUrl)
            };
            uploadRequest.Content = uploadFile;
            uploadRequest.Headers.Add("x-ms-blob-type", "BlockBlob");
            var uploadResponse = await HTTP_CLIENT.SendAsync(uploadRequest).ConfigureAwait(false);
            Assert.IsTrue(uploadResponse.IsSuccessStatusCode);
            return;
        }

        private async Task<AudioNoteDetails> GetAudioTranscript(AudioNoteDetails audioNoteDetail, string userId = null)
        {
            userId ??= this.defaultUserId;
            Uri getUrl = new Uri($"{this.baseUrl}/{audioNoteDetail.Id}?userId={userId}");
            const string transcript = "No, that's not going to do it.";
            var transcribed = false;
            System.Diagnostics.Stopwatch watch = new System.Diagnostics.Stopwatch();
            watch.Start();
            while (watch.ElapsedMilliseconds < 10000 && !transcribed)
            {
                var getAudioTranscriptCheckResponse = await HTTP_CLIENT.GetAsync(getUrl).ConfigureAwait(false);
                var getAudioTranscriptCheckResponseContent = await getAudioTranscriptCheckResponse.Content.ReadAsStringAsync().ConfigureAwait(false);
                audioNoteDetail = JsonConvert.DeserializeObject<Models.Responses.AudioNoteDetails>(getAudioTranscriptCheckResponseContent);
                if (audioNoteDetail.Transcript == transcript)
                {
                    transcribed = true;
                }
                await Task.Delay(1000).ConfigureAwait(false);
            }
            Assert.IsTrue(transcribed);
            return audioNoteDetail;
        }

        private async Task DeleteAudio(AudioNoteDetails audioNoteDetail, string userId = null)
        {
            userId ??= this.defaultUserId;
            Uri noteUrl = new Uri($"{this.baseUrl}/{audioNoteDetail.Id}?userId={userId}");
            var deleteResponse = await HTTP_CLIENT.DeleteAsync(noteUrl).ConfigureAwait(false);
            Assert.IsTrue(deleteResponse.StatusCode == System.Net.HttpStatusCode.NoContent);
            return;
        }
    }
}
