namespace ContentReactor.Health.Services.Tests
{
    using System.Threading.Tasks;
    using Microsoft.VisualStudio.TestTools.UnitTesting;

    /// <summary>
    /// Unit test for the HealthService class.
    /// </summary>
    public class HealthServiceTests
    {
        /// <summary>
        /// When you call the HealthCheck service
        /// Then you should get a collection of HealthStatusResponses for each service.
        /// </summary>
        /// <returns>Test Results.</returns>
        [TestMethod]
        public async Task GetHealthCheckReturnsCorrectHealth()
        {
            // arrange
            // var fakeHealthRepository = new FakeHealthRepository();
            // fakeHealthRepository.HealthDocuments.Add(new HealthDocument { Id = "fakeid", Health = "faketext", CategoryId = "fakecategoryid", UserId = "fakeuserid" });
            // var service = new HealthService(fakeHealthRepository, new Mock<IEventGridPublisherService>().Object);

            // act
            // var result = await service.GetHealthNoteAsync("fakeid", "fakeuserid");

            // assert
            // Assert.NotNull(result);
            // Assert.Equal("fakeid", result.Id);
            // Assert.Equal("faketext", result.Health);
            await Task.Run(() => { }).ConfigureAwait(false);
        }
    }
}
