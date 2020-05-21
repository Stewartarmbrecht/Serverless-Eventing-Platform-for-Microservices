namespace ContentReactor.Categories.Tests.UnitTests
{
    using System.Linq;
    using System.Threading.Tasks;
    using ContentReactor.Categories.Services;
    using ContentReactor.Common;
    using ContentReactor.Common.EventSchemas.Categories;
    using ContentReactor.Common.Events;
    using Microsoft.Extensions.Localization;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Moq;

    /// <summary>
    /// Contains all unit tests for the Categories service add functionality.
    /// </summary>
    [TestClass]
    public class CategoriesServiceAddTests
    {
        /// <summary>
        /// Given you have a valid category
        /// When you pass it to the cateogry add operation
        /// Then you should get back a new id for the category.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task AddCategoryReturnsDocumentId()
        {
            var fakeCategoriesRepository = new FakeCategoriesRepository();

            // arrange
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.AddCategoryAsync("name", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.IsNotNull(result);
            Assert.IsFalse(string.IsNullOrEmpty(result));
        }

        /// <summary>
        /// Given you have an instance of the category service
        /// When you add a category using the AddCategoryAsync operation
        /// Then the service should add the new category to the category repository.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task AddCategoryAddsDocumentToRepository()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            await service.AddCategoryAsync("name", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.AreEqual(1, fakeCategoriesRepository.CategoryDocuments.Count);
            Assert.IsTrue(fakeCategoriesRepository.CategoryDocuments.Any(d => d.Name == "name" && d.UserId == "fakeuserid"));
        }

        /// <summary>
        /// Given you have an instance of the category service
        /// When you add a category using the AddCategoryAsync operation
        /// Then the service should publish the add event to the even grid.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task AddCategoryPublishesCategoryCreatedEventToEventGrid()
        {
            // arrange
            var mockEventGridPublisherService = new Mock<IEventGridPublisherService>();
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                mockEventGridPublisherService.Object);

            // act
            var categoryId = await service.AddCategoryAsync("name", "fakeuserid").ConfigureAwait(false);

            // assert
            mockEventGridPublisherService.Verify(
                m => m.PostEventGridEventAsync(
                    CategoryEvents.CategoryCreated,
                    $"fakeuserid/{categoryId}",
                    It.Is<CategoryCreatedEventData>(d => d.Name == "name")),
                Times.Once);
        }
    }
}
