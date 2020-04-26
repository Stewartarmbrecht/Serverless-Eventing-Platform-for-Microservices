namespace ContentReactor.Categories.Tests.UnitTests
{
    using System.Threading.Tasks;
    using ContentReactor.Categories.Services;
    using ContentReactor.Categories.Services.Models.Data;
    using ContentReactor.Categories.Services.Models.Results;
    using ContentReactor.Common;
    using ContentReactor.Common.EventSchemas.Categories;
    using ContentReactor.Common.Events;
    using Microsoft.Extensions.Localization;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Moq;

    /// <summary>
    /// Contains all unit tests for the Categories service delete operation.
    /// </summary>
    [TestClass]
    public class CategoriesServiceDeleteTests
    {
        /// <summary>
        /// Given you have an instance of the category service
        /// And the category service has a category
        /// When you delete a category using the DeleteCategoryAsync operation
        /// Then the service should response with a success status code
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task DeleteCategoryReturnsSuccess()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid", UserId = "fakeuserid" });
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.DeleteCategoryAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.AreEqual(DeleteCategoryResult.Success, result);
        }

        /// <summary>
        /// Given you have an instance of the category service
        /// And the category service has a category
        /// When you delete a category using the DeleteCategoryAsync operation
        /// Then the service should delete the document from the repository.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task DeleteCategoryDeletesDocumentFromRepository()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid", UserId = "fakeuserid" });
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            await service.DeleteCategoryAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.IsTrue(fakeCategoriesRepository.CategoryDocuments.Count == 0);
        }

        /// <summary>
        /// Given you have an instance of the category service
        /// And the category service has a category
        /// When you delete a category using the DeleteCategoryAsync operation
        /// Then the service should post the delete event to the event grid.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task DeleteCategoryPublishesCategoryDeletedEventToEventGrid()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid", UserId = "fakeuserid" });
            var mockEventGridPublisherService = new Mock<IEventGridPublisherService>();
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                mockEventGridPublisherService.Object);

            // act
            await service.DeleteCategoryAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            mockEventGridPublisherService.Verify(
                m => m.PostEventGridEventAsync(
                    CategoryEvents.CategoryDeleted,
                    "fakeuserid/fakeid",
                    It.IsAny<CategoryDeletedEventData>()),
                Times.Once);
        }

        /// <summary>
        /// Given you have an instance of the category service
        /// And the category service does not have a category
        /// When you delete a category using the DeleteCategoryAsync operation
        /// Then the service should respond with a not found status code
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task DeleteCategoryInvalidCategoryIdReturnsNotFound()
        {
            var fakeCategoriesRepository = new FakeCategoriesRepository();

            // arrange
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.DeleteCategoryAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.AreEqual(DeleteCategoryResult.NotFound, result);
        }

        /// <summary>
        /// Given you have an instance of the category service
        /// And the category service has a category for a different user
        /// When you delete a category using the DeleteCategoryAsync operation with a different user id
        /// Then the service should response with a not found status code
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task DeleteCategoryIncorrectUserIdReturnsNotFound()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid", UserId = "fakeuserid2" });
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.DeleteCategoryAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.AreEqual(DeleteCategoryResult.NotFound, result);
        }
    }
}
