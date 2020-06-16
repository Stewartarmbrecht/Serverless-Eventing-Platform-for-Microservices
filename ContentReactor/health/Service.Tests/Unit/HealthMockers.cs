namespace ContentReactor.Health.Service.Tests.Unit
{
    using ContentReactor.Common.Fakes;
    using ContentReactor.Common.UserAuthentication;
    using ContentReactor.Health.Service;
    using Moq;

    /// <summary>
    /// Helper functions to get mocks for health unit testing.
    /// </summary>
    public static class HealthMockers
    {
        /// <summary>
        /// Gets an audio operations class with a blob uploaded to the mock
        /// blob repository.
        /// </summary>
        /// <param name="mockUserAuth">Returns the mock user auth.</param>
        /// <param name="mockHealthService">Returns the mock health service.</param>
        /// <returns>An instance of the <see cref="Functions"/> class.</returns>
        public static Functions GetApiFunctions(
            out Mock<IUserAuthenticationService> mockUserAuth,
            out Mock<IHealthService> mockHealthService)
        {
            mockUserAuth = Mockers.MockUserAuth();
            mockHealthService = new Mock<IHealthService>();

            return new Functions(mockUserAuth.Object, mockHealthService.Object);
        }
    }
}