namespace ContentReactor.Categories.Tests.UnitTests
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading.Tasks;
    using ContentReactor.Categories.Services;
    using ContentReactor.Categories.Services.Models.Data;
    using ContentReactor.Categories.Services.Models.Response;
    using ContentReactor.Categories.Services.Repositories;
    using ContentReactor.Common;
    using Microsoft.Extensions.Localization;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Moq;

    /// <summary>
    /// Contains all unit tests for the Categories service Get and List operations.
    /// </summary>
    [TestClass]
    public class CategoriesServiceGetTests
    {
        /// <summary>
        /// Given you have an instance of the category service
        /// And the category service has a category
        /// When you get a category using the GetCategoryAsync operation
        /// Then the service should respond with the category details
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task GetCategoryReturnsCorrectText()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(
                new CategoryDocument
                {
                    Id = "fakeid",
                    Name = "fakename",
                    UserId = "fakeuserid",
                    ImageUrl = new Uri("https://www.edenimageurl.com/"),
                });
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            CategoryDetails result = await service.GetCategoryAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.IsNotNull(result);
            Assert.AreEqual("fakeid", result.Id);
            Assert.AreEqual("fakename", result.Name);
            Assert.AreEqual("https://www.edenimageurl.com/", result.ImageUrl.ToString());
        }

        /// <summary>
        /// Given you have an instance of the category service
        /// When you get a category using the GetCategoryAsync operation and an invalid category id
        /// Then the service should respond with a null result
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task GetCategoryInvalidCategoryIdReturnsNull()
        {
            // arrange
            var service = new CategoriesService(
                new Mock<ICategoriesRepository>().Object,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.GetCategoryAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.IsNull(result);
        }

        /// <summary>
        /// Given you have an instance of the category service
        /// And the category service has a category
        /// When you get a category using the GetCategoryAsync operation with a valid category id but invalid user id
        /// Then the service should respond with the category details
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task GetCategoryIncorrectUserIdReturnsNull()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid", Name = "fakename", UserId = "fakeuserid2" });
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.GetCategoryAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.IsNull(result);
        }

        /// <summary>
        /// Given you have an instance of the category service
        /// And the category service has 2 categories
        /// When you list the categories using the ListCategoriesAsync operation
        /// Then the service should respond with the 2 category summaries
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task ListCategoriesReturnsIds()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid1", Name = "fakename1", UserId = "fakeuserid" });
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid2", Name = "fakename2", UserId = "fakeuserid" });
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.ListCategoriesAsync("fakeuserid").ConfigureAwait(false);

            // assert
            Assert.AreEqual(2, result.Count);
            var comparer = new CategorySummaryComparer();
            Assert.IsTrue(result.Contains(new CategorySummary { Id = "fakeid1", Name = "fakename1" }, comparer));
            Assert.IsTrue(result.Contains(new CategorySummary { Id = "fakeid2", Name = "fakename2" }, comparer));
        }

        /// <summary>
        /// Given you have an instance of the category service
        /// And the category service has 2 categories for different users
        /// When you list the categories using the ListCategoriesAsync operation for one user id
        /// Then the service should respond with the category summary for one category that matches for the user
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task ListCategoriesDoesNotReturnsIdsForAnotherUser()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid1", Name = "fakename1", UserId = "fakeuserid1" });
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid2", Name = "fakename2", UserId = "fakeuserid2" });
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.ListCategoriesAsync("fakeuserid1").ConfigureAwait(false);

            // assert
            Assert.IsTrue(result.Count == 1);
            var comparer = new CategorySummaryComparer();
            Assert.IsTrue(result.Contains(new CategorySummary { Id = "fakeid1", Name = "fakename1" }, comparer));
        }

        private class CategorySummaryComparer : IEqualityComparer<CategorySummary>
        {
            public bool Equals(CategorySummary x, CategorySummary y) => x.Id == y.Id &&
                                                                        x.Name == y.Name;

            public int GetHashCode(CategorySummary obj) => obj.GetHashCode();
        }
    }
}
