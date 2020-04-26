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
    /// Contains all unit tests for the Categories service update category image operation.
    /// </summary>
    [TestClass]
    public class CategoriesServiceUpdateImageTests
    {
        /// <summary>
        /// Given you have a category service
        /// And the category service has a category defined
        /// When you update the category image using the UpdateCategoryImageAsync operation
        /// Then you should get a boolean result of true from the call.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task UpdateCategoryImageReturnsTrue()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid", Name = "fakename", UserId = "fakeuserid" });
            var mockImageSearchService = new Mock<IImageSearchService>();
            mockImageSearchService
                .Setup(m => m.FindImageUrlAsync("fakename"))
                .ReturnsAsync(new Uri("http://fake/imageurl.jpg"));
            var service = new CategoriesService(
                fakeCategoriesRepository,
                mockImageSearchService.Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.UpdateCategoryImageAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.IsTrue(result);
        }

        /// <summary>
        /// Given you have a category service
        /// And the category service has a category defined
        /// When you update the category image using the UpdateCategoryImageAsync operation
        /// Then the service should update the ImageUrl property of the category.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task UpdateCategoryImageUpdatesCategoryDocumentWithImageUrl()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid", Name = "fakename", UserId = "fakeuserid" });
            var mockImageSearchService = new Mock<IImageSearchService>();
            mockImageSearchService
                .Setup(m => m.FindImageUrlAsync("fakename"))
                .ReturnsAsync(new Uri("http://fake/imageurl.jpg"));
            var service = new CategoriesService(
                fakeCategoriesRepository,
                mockImageSearchService.Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            await service.UpdateCategoryImageAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.AreEqual("http://fake/imageurl.jpg", fakeCategoriesRepository.CategoryDocuments.Single().ImageUrl.ToString());
        }

        /// <summary>
        /// Given you have a category service
        /// And the category service has a category defined
        /// When you update the category image using the UpdateCategoryImageAsync operation
        /// Then the service should publish the CategoryImageUpdated event.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task UpdateCategoryImagePublishesCategoryImageUpdatedEventToEventGrid()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid", Name = "fakename", UserId = "fakeuserid" });
            var mockEventGridPublisherService = new Mock<IEventGridPublisherService>();
            var mockImageSearchService = new Mock<IImageSearchService>();
            mockImageSearchService
                .Setup(m => m.FindImageUrlAsync("fakename"))
                .ReturnsAsync(new Uri("http://fake/imageurl.jpg"));
            var service = new CategoriesService(
                fakeCategoriesRepository,
                mockImageSearchService.Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

                // mockEventGridPublisherService.Object,
                // new Mock<IStringLocalizer>().Object);

            // act
            await service.UpdateCategoryImageAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            mockEventGridPublisherService.Verify(
                m => m.PostEventGridEventAsync(
                    CategoryEvents.CategoryImageUpdated,
                    "fakeuserid/fakeid",
                    It.Is<CategoryImageUpdatedEventData>(c => c.ImageUrl.ToString() == "http://fake/imageurl.jpg")),
                Times.Once);
        }

        /// <summary>
        /// Given you have a category service
        /// And the category service has a category defined
        /// When you update the category image using the UpdateCategoryImageAsync operation
        /// And there is not matching image for the category
        /// Then you should get a boolean result of false from the call.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task UpdateCategoryImageImageNotFoundReturnsFalse()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid", Name = "fakename", UserId = "fakeuserid" });
            var mockImageSearchService = new Mock<IImageSearchService>();
            mockImageSearchService
                .Setup(m => m.FindImageUrlAsync("fakename"))
                .ReturnsAsync(() => null);
            var service = new CategoriesService(
                fakeCategoriesRepository,
                mockImageSearchService.Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.UpdateCategoryImageAsync("fakeid", "fakeuserid").ConfigureAwait(false);

            // assert
            Assert.IsFalse(result);
        }

        /// <summary>
        /// Given you have a category service
        /// And the category service has a category defined
        /// And the category name has a matching image
        /// When you update the category image using the UpdateCategoryImageAsync operation with an invalid user id
        /// Then you should get a boolean result of false from the call.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task UpdateCategoryImageUserIdIncorrectReturnsFalse()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid", Name = "fakename", UserId = "fakeuserid1" });
            var mockImageSearchService = new Mock<IImageSearchService>();
            mockImageSearchService
                .Setup(m => m.FindImageUrlAsync("fakename"))
                .ReturnsAsync(new Uri("http://fake/imageurl.jpg"));
            var service = new CategoriesService(
                fakeCategoriesRepository,
                mockImageSearchService.Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            var result = await service.UpdateCategoryImageAsync("fakeid", "fakeuserid2").ConfigureAwait(false);

            // assert
            Assert.IsFalse(result);
        }

        /// <summary>
        /// Given you have a category service
        /// And the category service has a category defined
        /// And the category name has a matching image
        /// When you update the category image using the UpdateCategoryImageAsync operation with an invalid user id
        /// Then the service should not update the image user for the category.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task UpdateCategoryImageUserIdIncorrectDoesNotUpdateCategoryDocumentWithImageUrl()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakeid", Name = "fakename", UserId = "fakeuserid1" });
            var mockImageSearchService = new Mock<IImageSearchService>();
            mockImageSearchService
                .Setup(m => m.FindImageUrlAsync("fakename"))
                .ReturnsAsync(new Uri("http://fake/imageurl.jpg"));
            var service = new CategoriesService(
                fakeCategoriesRepository,
                mockImageSearchService.Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            // act
            await service.UpdateCategoryImageAsync("fakeid", "fakeuserid2").ConfigureAwait(false);

            // assert
            Assert.IsNull(fakeCategoriesRepository.CategoryDocuments.Single().ImageUrl);
        }
    }
}
