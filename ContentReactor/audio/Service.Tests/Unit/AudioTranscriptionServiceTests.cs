namespace ContentReactor.Audio.Service.Tests.Unit
{
    using System;
    using System.IO;
    using ContentReactor.Audio.Service;
    using Microsoft.VisualStudio.TestTools.UnitTesting;

    /// <summary>
    /// Tests the audio transcription service.
    /// </summary>
    [TestClass]
    public class AudioTranscriptionServiceTests
    {
        /// <summary>
        /// Given you have a memory stream
        /// When you call the CreateAudioTranscriptionRequest and pass in the stream
        /// Then the service should return a result that is not null.
        /// </summary>
        [TestMethod]
        public void CreateAudioTranscriptRequestReturnsExpectedRequest()
        {
            // arrange
            Environment.SetEnvironmentVariable("CognitiveServicesSpeechApiEndpoint", "http://fakeendpoint");
            Environment.SetEnvironmentVariable("CognitiveServicesSpeechApiKey", "fakekey");
            var stream = new MemoryStream();

            // act
            var result = AudioTranscriptionService.CreateAudioTranscriptRequest(stream);

            // assert
            Assert.IsNotNull(result);
        }

        /// <summary>
        /// Given you have a valid response from the Microsoft Cognitive Services Speech to Text api
        /// When you call the ProcessAudioTranscriptResponse and pass in the string representation of the response
        /// Then the service should return the display value of the best match included in the results.
        /// </summary>
        [TestMethod]
        public void ProcessAudioTranscriptResponseReturnsExpectedResponse()
        {
            // arrange
            const string responseString = "{\"RecognitionStatus\":\"Success\",\"Offset\":3600000,\"Duration\":89800000,\"NBest\":[{\"Confidence\":0.940092,\"Lexical\":\"hi i\'m brian one of the available high-quality text to speech voices select download not to install my voice\",\"ITN\":\"hi I\'m Brian one of the available high-quality text to speech voices select download not to install my voice\",\"MaskedITN\":\"hi I\'m Brian one of the available high-quality text to speech voices select download not to install my voice\",\"Display\":\"Hi I\'m Brian one of the available high-quality text to speech voices select download not to install my voice.\"},{\"Confidence\":0.929836333,\"Lexical\":\"hi i\'m brian one of the available high-quality text to speech voices select download now to install my voice\",\"ITN\":\"hi I\'m Brian one of the available high-quality text to speech voices select download now to install my voice\",\"MaskedITN\":\"hi I\'m Brian one of the available high-quality text to speech voices select download now to install my voice\",\"Display\":\"Hi I\'m Brian one of the available high-quality text to speech voices select download now to install my voice.\"},{\"Confidence\":0.9099141,\"Lexical\":\"hi i\'m bryan one of the available high-quality text to speech voices select download not to install my voice\",\"ITN\":\"hi I\'m Bryan one of the available high-quality text to speech voices select download not to install my voice\",\"MaskedITN\":\"hi I\'m Bryan one of the available high-quality text to speech voices select download not to install my voice\",\"Display\":\"Hi I\'m Bryan one of the available high-quality text to speech voices select download not to install my voice.\"},{\"Confidence\":0.9099141,\"Lexical\":\"hi i\'m brian one of the available high-quality text to speech voices select download not too install my voice\",\"ITN\":\"hi I\'m Brian one of the available high-quality text to speech voices select download not too install my voice\",\"MaskedITN\":\"hi I\'m Brian one of the available high-quality text to speech voices select download not too install my voice\",\"Display\":\"Hi I\'m Brian one of the available high-quality text to speech voices select download not too install my voice.\"},{\"Confidence\":0.8996583,\"Lexical\":\"hi i\'m bryan one of the available high-quality text to speech voices select download now to install my voice\",\"ITN\":\"hi I\'m Bryan one of the available high-quality text to speech voices select download now to install my voice\",\"MaskedITN\":\"hi I\'m Bryan one of the available high-quality text to speech voices select download now to install my voice\",\"Display\":\"Hi I\'m Bryan one of the available high-quality text to speech voices select download now to install my voice.\"}]}";

            // act
            var response = AudioTranscriptionService.ProcessAudioTranscriptResponse(responseString);

            // assert
            Assert.AreEqual("Hi I'm Brian one of the available high-quality text to speech voices select download not to install my voice.", response);
        }
    }
}
