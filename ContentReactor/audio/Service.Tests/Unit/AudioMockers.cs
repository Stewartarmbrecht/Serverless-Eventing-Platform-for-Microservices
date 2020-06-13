namespace ContentReactor.Audio.Service.Tests.Unit
{
    using ContentReactor.Common.Events;
    using ContentReactor.Common.Events.Audio;
    using ContentReactor.Common.Fakes;
    using ContentReactor.Common.UserAuthentication;
    using Microsoft.AspNetCore.Http;
    using Moq;
    using Api = ContentReactor.Audio.Service;

    /// <summary>
    /// Helper functions to get mocks for audio unit testing.
    /// </summary>
    public static class AudioMockers
    {
        /// <summary>
        /// Gets a mocked audio add complete request.
        /// </summary>
        /// <returns>Mock http request with an audio add complete request in the body.</returns>
        public static Mock<HttpRequest> GetMockAddCompleteRequest()
        {
            var requestBody = new Api.AddCompleteRequest()
            {
                CategoryId = Mockers.DefaultCategoryName,
            };

            return Mockers.MockRequest(requestBody);
        }

        /// <summary>
        /// Gets a mocked event grid update transcription request.
        /// </summary>
        /// <returns>Mock http request that would come from the event grid for an audio created event.</returns>
        public static Mock<HttpRequest> GetMockEventGridAudioCreatedRequest()
        {
            var requestBody = new EventGridRequest<AudioCreatedEventData>()
            {
                UserId = Mockers.DefaultUserId,
                ItemId = Mockers.DefaultId,
                Event = new EventGridEvent<AudioCreatedEventData>()
                {
                    Data = new AudioCreatedEventData()
                    {
                        Category = Mockers.DefaultId,
                    },
                    EventTime = System.DateTime.Now,
                    Id = System.Guid.NewGuid().ToString(),
                    EventType = "AudioCreated",
                    Subject = $"{Mockers.DefaultUserId}/{Mockers.DefaultId}",
                    Topic = "faketopic",
                },
            };

            var headers = new HeaderDictionary();

            return Mockers.MockRequest(requestBody, headers);
        }

        /// <summary>
        /// Gets an audio operations class with a blob uploaded to the mock
        /// blob repository.
        /// </summary>
        /// <returns>An instance of the <see cref="Api.Functions"/> class.</returns>
        public static Api.Functions GetApiFunctionsWithBlobUploaded()
        {
            return GetApiFunctionsWithBlobUploaded(
                out Mock<IUserAuthenticationService> mockUserAuth,
                out FakeBlobRepository fakeBlobRepository,
                out Mock<IEventGridPublisherService> mockEventPub);
        }

        /// <summary>
        /// Gets an audio operations class with a blob uploaded to the mock
        /// blob repository.
        /// </summary>
        /// <param name="fakeBlobRepo">Returns the fake blob repository with the added blob.</param>
        /// <returns>An instance of the <see cref="Api.Functions"/> class.</returns>
        public static Api.Functions GetApiFunctionsWithBlobUploaded(
            out FakeBlobRepository fakeBlobRepo)
        {
            return GetApiFunctionsWithBlobUploaded(
                out Mock<IUserAuthenticationService> mockUserAuth,
                out fakeBlobRepo,
                out Mock<IEventGridPublisherService> mockEventPub);
        }

        /// <summary>
        /// Gets an audio operations class with a blob uploaded to the mock
        /// blob repository.
        /// </summary>
        /// <param name="fakeBlobRepo">Returns the fake blob repository with the added blob.</param>
        /// <param name="mockEventPub">Returns the mock event publisher service.</param>
        /// <returns>An instance of the <see cref="Api.Functions"/> class.</returns>
        public static Api.Functions GetApiFunctionsWithBlobUploaded(
            out FakeBlobRepository fakeBlobRepo,
            out Mock<IEventGridPublisherService> mockEventPub)
        {
            return GetApiFunctionsWithBlobUploaded(
                out Mock<IUserAuthenticationService> mockUserAuth,
                out fakeBlobRepo,
                out mockEventPub);
        }

        /// <summary>
        /// Gets an audio operations class with a blob uploaded to the mock
        /// blob repository.
        /// </summary>
        /// <param name="mockUserAuth">Returns the mock user auth service.</param>
        /// <returns>An instance of the <see cref="Api.Functions"/> class.</returns>
        public static Api.Functions GetApiFunctionsWithBlobUploaded(
            out Mock<IUserAuthenticationService> mockUserAuth)
        {
            return GetApiFunctionsWithBlobUploaded(
                out mockUserAuth,
                out FakeBlobRepository fakeBlobRepo,
                out Mock<IEventGridPublisherService> mockEventPub,
                out Mock<IEventGridSubscriberService> mockEventSub,
                out Mock<Api.IAudioTranscriptionService> mockTranscriptService);
        }

        /// <summary>
        /// Gets an audio operations class with a blob uploaded to the mock
        /// blob repository.
        /// </summary>
        /// <param name="mockUserAuth">Returns the mock user auth.</param>
        /// <param name="fakeBlobRepo">Returns the fake blob repository with the added blob.</param>
        /// <param name="mockEventPub">Returns the fake event publisher.</param>
        /// <returns>An instance of the <see cref="Api.Functions"/> class.</returns>
        public static Api.Functions GetApiFunctionsWithBlobUploaded(
            out Mock<IUserAuthenticationService> mockUserAuth,
            out FakeBlobRepository fakeBlobRepo,
            out Mock<IEventGridPublisherService> mockEventPub)
        {
            mockUserAuth = Mockers.MockUserAuth();

            mockEventPub = new Mock<IEventGridPublisherService>();
            var mockEventSub = new Mock<IEventGridSubscriberService>();
            var mockAudioTranscriptionService = new Mock<Api.IAudioTranscriptionService>();

            fakeBlobRepo = new FakeBlobRepository();
            fakeBlobRepo.AddFakeBlob(Mockers.AudioContainerName, $"{Mockers.DefaultUserId}/{Mockers.DefaultId}");

            return new Api.Functions(
                mockUserAuth.Object,
                fakeBlobRepo,
                mockEventSub.Object,
                mockEventPub.Object,
                mockAudioTranscriptionService.Object);
        }

        /// <summary>
        /// Gets an audio worker functions class with a blob uploaded to the mock
        /// blob repository.
        /// </summary>
        /// <param name="mockUserAuth">Returns the mock user auth.</param>
        /// <param name="fakeBlobRepo">Returns the fake blob repository with the added blob.</param>
        /// <param name="mockEventPub">Returns the fake event publisher.</param>
        /// <param name="mockEventSub">Returns the fake event subscriber.</param>
        /// <param name="mockAudioTranscriptionService">Returns the mock audio transcription service.</param>
        /// <returns>An instance of the <see cref="Api.Functions"/> class.</returns>
        public static Api.Functions GetApiFunctionsWithBlobUploaded(
            out Mock<IUserAuthenticationService> mockUserAuth,
            out FakeBlobRepository fakeBlobRepo,
            out Mock<IEventGridPublisherService> mockEventPub,
            out Mock<IEventGridSubscriberService> mockEventSub,
            out Mock<Api.IAudioTranscriptionService> mockAudioTranscriptionService)
        {
            mockUserAuth = Mockers.MockUserAuth();

            mockEventPub = new Mock<IEventGridPublisherService>();
            mockEventSub = new Mock<IEventGridSubscriberService>();
            mockAudioTranscriptionService = new Mock<Api.IAudioTranscriptionService>();

            fakeBlobRepo = new FakeBlobRepository();
            fakeBlobRepo.AddFakeBlob(Mockers.AudioContainerName, $"{Mockers.DefaultUserId}/{Mockers.DefaultId}");

            return new Api.Functions(
                mockUserAuth.Object,
                fakeBlobRepo,
                mockEventSub.Object,
                mockEventPub.Object,
                mockAudioTranscriptionService.Object);
        }
    }
}