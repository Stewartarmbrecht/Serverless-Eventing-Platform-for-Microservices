namespace ContentReactor.Categories.Tests.UnitTests
{
    using System.Threading.Tasks;
    using ContentReactor.Categories.Services;
    using ContentReactor.Categories.Services.Repositories;
    using ContentReactor.Common;
    using Microsoft.Extensions.Localization;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Moq;

    /// <summary>
    /// Contains all unit tests for the Categories service health checks.
    /// </summary>
    [TestClass]
    public class CategoriesServiceHealthCheckTests
    {
        /// <summary>
        /// Given you have a propperly running categories api service
        /// When you call the HealthCheckApi operation
        /// Then you should get a successful result.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task HealthCheckApiSuccess()
        {
            // arrange
            var service = new CategoriesService(
                new Mock<ICategoriesRepository>().Object,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.HealthCheckApi("mytest@test.com", "my-app-test").ConfigureAwait(false);

            // assert
            Assert.IsNotNull(result);
            Assert.AreEqual(HealthCheckStatus.OK, result.Status);
            Assert.AreEqual("my-app-test", result.Application);
        }

        /// <summary>
        /// Given you have a propperly running categories worker service
        /// When you call the HealthCheckWorker operation
        /// Then you should get a successful result.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task HealthCheckWorkerSuccess()
        {
            // arrange
            var service = new CategoriesService(
                new Mock<ICategoriesRepository>().Object,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.HealthCheckWorker("mytest@test.com", "my-app-test").ConfigureAwait(false);

            // assert
            Assert.IsNotNull(result);
            Assert.AreEqual(HealthCheckStatus.OK, result.Status);
            Assert.AreEqual("my-app-test", result.Application);
        }
    }
}
