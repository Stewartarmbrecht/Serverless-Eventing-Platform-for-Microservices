namespace ContentReactor.Categories.Tests.UnitTests
{
    using System;
    using System.Linq;
    using System.Threading.Tasks;
    using ContentReactor.Categories.Services;
    using ContentReactor.Categories.Services.Models.Data;
    using ContentReactor.Common;
    using ContentReactor.Common.EventSchemas.Categories;
    using ContentReactor.Common.Events;
    using Microsoft.Extensions.Localization;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Moq;

    /// <summary>
    /// Contains all unit tests for the Categories service update synonyms operation.
    /// </summary>
    [TestClass]
    public class CategoriesServiceUpdateSynonymsTests
    {
        /// <summary>
        /// Given you have a category service
        /// And the category service has a category defined
        /// When you update the category synonyms using the UpdateCategorySynonymsAsync operation
        /// Then you should get a boolean result of true from the call.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task UpdateCategorySynonymsReturnsTrue()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid", Name = "fakename", UserId = "fakeuserid" });
            var mockSynonymService = new Mock<ISynonymService>();
            mockSynonymService
                .Setup(m => m.GetSynonymsAsync("fakename"))
                .ReturnsAsync(new[] { "a", "b" });
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                mockSynonymService.Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.UpdateCategorySynonymsAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.IsTrue(result);
        }

        /// <summary>
        /// Given you have a category service
        /// And the category service has a category defined
        /// When you update the category synonyms using the UpdateCategorySynonymsAsync operation
        /// Then the service should update the synonyms for the category.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task UpdateCategorySynonymsUpdatesCategoryDocumentWithSynonyms()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid", Name = "fakename", UserId = "fakeuserid" });
            var mockSynonymService = new Mock<ISynonymService>();
            mockSynonymService
                .Setup(m => m.GetSynonymsAsync("fakename"))
                .ReturnsAsync(new[] { "a", "b" });
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                mockSynonymService.Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            await service.UpdateCategorySynonymsAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.AreEqual(2, fakeCategoriesRepository.CategoryDocuments.Single().Synonyms.Count);
            Assert.IsTrue(fakeCategoriesRepository.CategoryDocuments.Single().Synonyms.Contains("a"));
            Assert.IsTrue(fakeCategoriesRepository.CategoryDocuments.Single().Synonyms.Contains("b"));
        }

        /// <summary>
        /// Given you have a category service
        /// And the category service has a category defined
        /// When you update the category synonyms using the UpdateCategorySynonymsAsync operation
        /// Then service should publish the CategorySynonymsUpdated event.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task UpdateCategorySynonymsPublishesCategorySynonymsUpdatedEventToEventGrid()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid", Name = "fakename", UserId = "fakeuserid" });
            var mockEventGridPublisherService = new Mock<IEventGridPublisherService>();
            var mockSynonymService = new Mock<ISynonymService>();
            mockSynonymService
                .Setup(m => m.GetSynonymsAsync("fakename"))
                .ReturnsAsync(new[] { "a", "b" });
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                mockSynonymService.Object,
                mockEventGridPublisherService.Object);

            // act
            await service.UpdateCategorySynonymsAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            mockEventGridPublisherService.Verify(
                m => m.PostEventGridEventAsync(
                    CategoryEvents.CategorySynonymsUpdated,
                    "fakeuserid/fakeid",
                    It.Is<CategorySynonymsUpdatedEventData>(c => c.Synonyms.Contains("a") && c.Synonyms.Contains("b"))),
                Times.Once);
        }

        /// <summary>
        /// Given you have a category service
        /// And the category service has a category defined
        /// And the category name does not have any synonyms
        /// When you update the category synonyms using the UpdateCategorySynonymsAsync operation
        /// Then you should get a boolean result of false from the call.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task UpdateCategorySynonymsSynonymsNotFoundReturnsFalse()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid", Name = "fakename", UserId = "fakeuserid" });
            var mockSynonymService = new Mock<ISynonymService>();
            mockSynonymService
                .Setup(m => m.GetSynonymsAsync("fakename"))
                .ReturnsAsync((string[])null);
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                mockSynonymService.Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.UpdateCategorySynonymsAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.IsFalse(result);
        }

        /// <summary>
        /// Given you have a category service
        /// And the category service has a category defined
        /// And the category name has synonyms
        /// When you update the category synonyms using the UpdateCategorySynonymsAsync operation and an invalid user id
        /// Then you should get a boolean result of false from the call.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task UpdateCategorySynonymsUserIdIncorrectReturnsFalse()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid", Name = "fakename", UserId = "fakeuserid1" });
            var mockSynonymService = new Mock<ISynonymService>();
            mockSynonymService
                .Setup(m => m.GetSynonymsAsync("fakename"))
                .ReturnsAsync(new[] { "a", "b" });
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                mockSynonymService.Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.UpdateCategorySynonymsAsync("fakeid", "fakeuserid2").ConfigureAwait(false);

            // assert
            Assert.IsFalse(result);
        }

        /// <summary>
        /// Given you have a category service
        /// And the category service has a category defined
        /// And the category name has synonyms
        /// When you update the category synonyms using the UpdateCategorySynonymsAsync operation with an invlid user id
        /// Then the service should not update the category with the synonyms
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task UpdateCategorySynonymsUserIdIncorrectDoesNotUpdateCategoryDocumentWithSynonyms()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid", Name = "fakename", UserId = "fakeuserid1" });
            var mockSynonymService = new Mock<ISynonymService>();
            mockSynonymService
                .Setup(m => m.GetSynonymsAsync("fakename"))
                .ReturnsAsync(new[] { "a", "b" });
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                mockSynonymService.Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            await service.UpdateCategorySynonymsAsync("fakeid", "fakeuserid2").ConfigureAwait(false);

            // assert
            Assert.AreEqual(0, fakeCategoriesRepository.CategoryDocuments.Single().Synonyms.Count);
        }
    }
}
