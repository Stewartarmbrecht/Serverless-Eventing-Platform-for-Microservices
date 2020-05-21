using System.Linq;
using System.Threading.Tasks;
using ContentReactor.Common;
using Moq;
using Xunit;

namespace ContentReactor.Health.Services.Tests
{
    public class HealthServiceTests
    {
        [Fact]
        public async Task GetHealthCheck_ReturnsCorrectHealth()
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
        }
    }
}
