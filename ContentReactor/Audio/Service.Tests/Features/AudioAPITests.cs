namespace ContentReactor.Audio.Service.Tests.Features
{
    using System;
    using System.Diagnostics.CodeAnalysis;
    using System.Net.Http;
    using System.Threading.Tasks;
    using ContentReactor.Audio.Service;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Newtonsoft.Json;

    /// <summary>
    /// Contains end to end tests for the Audio API.
    /// </summary>
    [TestClass]
    [TestCategory("Features")]
    public class AudioApiTests
    {
        private static readonly HttpClient HttpClientInstance = new HttpClient();
        private readonly string baseUrl = Environment.GetEnvironmentVariable("FeaturesUrl");
        private readonly string defaultUserId = "developer@edentest.com";

        /// <summary>
        /// Given you have an audio note
        /// When you add the audio note through the api
        /// Then you should be able to retrieve a url to download the note
        /// And the note should have the category that you specified when completing the upload
        /// And the note should have a transcription.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task AddAudioWithSuccess()
        {
            // Get the url to upload a new audio file.
            (string blobId, string blobUploadUrl) = await this.BeginAddAudio().ConfigureAwait(false);

            // Upload the audio file to the storage service.
            await UploadFile(blobUploadUrl).ConfigureAwait(false);

            // Complete the add of the new audio file with the audio service
            await this.EndAddAudio(blobId).ConfigureAwait(false);

            // Get the new audio file and validate its properties
            GetResponse getResponse = await this.GetAudioDetail(blobId).ConfigureAwait(false);

            // Check the blob to verify it is transcribed with in 10 seconds.
            // await this.GetAudioTranscript(getResponse).ConfigureAwait(false);
        }

        /// <summary>
        /// Given you have an audio note that you have added
        /// When you delete the audio note
        /// Then you should receive a complete message
        /// And the get operation should no longer return the note.
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task DeleteAudioWithSuccess()
        {
            // Add an audio note.
            GetResponse getResponse = await this.AddAudioNote().ConfigureAwait(false);

            // Delete the audio note.
            await this.DeleteAudio(getResponse).ConfigureAwait(false);

            // Get the deleted audio file and validate not found result.
            var missing = await this.GetMissingAudioDetail(getResponse.Id).ConfigureAwait(false);

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
            await this.AddAudioNote(firstUserId).ConfigureAwait(false);
            await this.AddAudioNote(firstUserId).ConfigureAwait(false);
            await this.AddAudioNote(secondUserId).ConfigureAwait(false);
            await this.AddAudioNote(secondUserId).ConfigureAwait(false);

            // Delete the audio note.
            var audioNotes = await this.ListAudioDetail(secondUserId).ConfigureAwait(false);

            // Validate result set.
            Assert.AreEqual(2, audioNotes.Count);
            Assert.IsNotNull(audioNotes[0].Id);
            Assert.IsNotNull(audioNotes[1].Id);
        }

        private static async Task UploadFile(string blobUploadUrl)
        {
            var audioFile = await System.IO.File.ReadAllBytesAsync("no-thats-not-gonna-do-it.wav").ConfigureAwait(false);
            Assert.IsNotNull(audioFile);
            var uploadFile = new ByteArrayContent(audioFile);
            using var uploadRequest = new HttpRequestMessage()
            {
                Method = HttpMethod.Put,
                RequestUri = new Uri(blobUploadUrl),
            };
            uploadRequest.Content = uploadFile;
            uploadRequest.Headers.Add("x-ms-blob-type", "BlockBlob");
            var uploadResponse = await HttpClientInstance.SendAsync(uploadRequest).ConfigureAwait(false);
            Assert.IsTrue(uploadResponse.IsSuccessStatusCode);
            return;
        }

        private async Task<GetResponse> AddAudioNote(string userId = null)
        {
            (string blobId, string blobUploadUrl) = await this.BeginAddAudio(userId).ConfigureAwait(false);

            // Upload the audio file to the storage service.
            await UploadFile(blobUploadUrl).ConfigureAwait(false);

            // Complete the add of the new audio file with the audio service
            await this.EndAddAudio(blobId, userId).ConfigureAwait(false);

            // Get the new audio file and validate its properties
            GetResponse getResponse = await this.GetAudioDetail(blobId, userId).ConfigureAwait(false);
            return getResponse;
        }

        [SuppressMessage("StyleCop.CSharp.SpacingRules", "SA1009:ClosingParenthesisMustBeSpacedCorrectly", Justification = "Reviewed.")]
        private async Task<(string blobId, string blobUploadUrl)> BeginAddAudio(string userId = null)
        {
            userId ??= this.defaultUserId;
            Uri postUri = new Uri($"{this.baseUrl}?userId={userId}");
            var beginAddResponse = await HttpClientInstance.PostAsync(postUri, null).ConfigureAwait(false);
            var beginAddResponseContent = await beginAddResponse.Content.ReadAsStringAsync().ConfigureAwait(false);
            dynamic beginAddResult = JsonConvert.DeserializeObject(beginAddResponseContent);
            var blobId = (string)beginAddResult.id;
            var blobUploadUrl = (string)beginAddResult.url;
            Assert.IsNotNull(blobId);
            Assert.IsNotNull(blobUploadUrl);
            return (blobId, blobUploadUrl);
        }

        private async Task<GetResponse> GetAudioDetail(string blobId, string userId = null)
        {
            userId ??= this.defaultUserId;
            Uri getUrl = new Uri($"{this.baseUrl}/{blobId}?userId={userId}");
            var getResponse = await HttpClientInstance.GetAsync(getUrl).ConfigureAwait(false);
            var getResponseContent = await getResponse.Content.ReadAsStringAsync().ConfigureAwait(false);
            GetResponse getResponseBody =
                JsonConvert.DeserializeObject<GetResponse>(getResponseContent);
            Assert.AreEqual(blobId, getResponseBody.Id);
            string downloadUrlEnd = $".blob.core.windows.net/audio/{userId}/{blobId}";
            Assert.IsTrue(
                getResponseBody.AudioUrl.ToString().Contains(downloadUrlEnd, StringComparison.Ordinal),
                $"{getResponseBody.AudioUrl} did not contain the string {downloadUrlEnd}");
            return getResponseBody;
        }

        private async Task<GetListResponse> ListAudioDetail(string userId = null)
        {
            userId ??= this.defaultUserId;
            Uri getUrl = new Uri($"{this.baseUrl}?userId={userId}");
            var getResponse = await HttpClientInstance.GetAsync(getUrl).ConfigureAwait(false);
            var getResponseContent = await getResponse.Content.ReadAsStringAsync().ConfigureAwait(false);
            GetListResponse audioNotes = JsonConvert.DeserializeObject<GetListResponse>(getResponseContent);
            return audioNotes;
        }

        private async Task<bool> GetMissingAudioDetail(string blobId, string userId = null)
        {
            userId ??= this.defaultUserId;
            Uri getUrl = new Uri($"{this.baseUrl}/{blobId}?userId={userId}");
            var getResponse = await HttpClientInstance.GetAsync(getUrl).ConfigureAwait(false);
            return getResponse.StatusCode == System.Net.HttpStatusCode.NotFound;
        }

        private async Task EndAddAudio(string blobId, string userId = null)
        {
            userId ??= this.defaultUserId;
            Uri endAddUrl = new Uri($"{this.baseUrl}/{blobId}?userId={userId}");
            using var endAddContent = new StringContent("{\"categoryId\":\"My Test\"}");
            var endAddResponse = await HttpClientInstance.PostAsync(endAddUrl, endAddContent).ConfigureAwait(false);
            Assert.IsTrue(endAddResponse.StatusCode == System.Net.HttpStatusCode.NoContent);
            return;
        }

        private async Task<GetResponse> GetAudioTranscript(GetResponse audioNoteDetail, string userId = null)
        {
            userId ??= this.defaultUserId;
            Uri getUrl = new Uri($"{this.baseUrl}/{audioNoteDetail.Id}?userId={userId}");
            const string transcript = "No, that's not going to do it.";
            var transcribed = false;
            System.Diagnostics.Stopwatch watch = new System.Diagnostics.Stopwatch();
            watch.Start();
            while (watch.ElapsedMilliseconds < 10000 && !transcribed)
            {
                var getAudioTranscriptCheckResponse = await HttpClientInstance.GetAsync(getUrl).ConfigureAwait(false);
                var getAudioTranscriptCheckResponseContent = await getAudioTranscriptCheckResponse.Content.ReadAsStringAsync().ConfigureAwait(false);
                audioNoteDetail = JsonConvert.DeserializeObject<GetResponse>(getAudioTranscriptCheckResponseContent);
                if (audioNoteDetail.Transcript == transcript)
                {
                    transcribed = true;
                }

                await Task.Delay(1000).ConfigureAwait(false);
            }

            Assert.IsTrue(transcribed, "It took longer than 10 seconds to transcribe audio file.");
            return audioNoteDetail;
        }

        private async Task DeleteAudio(GetResponse audioNoteDetail, string userId = null)
        {
            userId ??= this.defaultUserId;
            Uri noteUrl = new Uri($"{this.baseUrl}/{audioNoteDetail.Id}?userId={userId}");
            var deleteResponse = await HttpClientInstance.DeleteAsync(noteUrl).ConfigureAwait(false);
            Assert.IsTrue(deleteResponse.StatusCode == System.Net.HttpStatusCode.NoContent);
            return;
        }
    }
}
