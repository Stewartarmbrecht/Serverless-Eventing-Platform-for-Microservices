namespace ContentReactor.Categories.Tests.UnitTests
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading.Tasks;
    using ContentReactor.Categories.Services;
    using ContentReactor.Categories.Services.Models;
    using ContentReactor.Categories.Services.Models.Data;
    using ContentReactor.Common;
    using ContentReactor.Common.Events.Audio;
    using ContentReactor.Common.EventSchemas.Categories;
    using ContentReactor.Common.EventSchemas.Images;
    using ContentReactor.Common.EventSchemas.Text;
    using ContentReactor.Common.Events;
    using Microsoft.Extensions.Localization;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Moq;

    /// <summary>
    /// Contains all unit tests for the Categories service processing of the item add event.
    /// </summary>
    [TestClass]
    public class CategoriesServiceItemAddTests
    {
        /// <summary>
        /// Given you have an instance of the category service
        /// And the category service has a category
        /// When you raise the TextCreated event with the same category id
        /// Then the service should add the category item preview to the category
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task ProcessAddItemEventAsyncAddsTextItem()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(
                new CategoryDocument
                {
                    Id = "fakecategoryid",
                    Name = "fakename",
                    UserId = "fakeuserid",
                });
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            var eventToProcess = new EventGridEvent
            {
                Subject = "fakeuserid/fakeitemid",
                EventType = TextEvents.TextCreated,
                Data = new TextCreatedEventData
                {
                    Category = "fakecategoryid",
                    Preview = "fakepreview"
                }
            };

            // act
            await service.ProcessAddItemEventAsync(eventToProcess, "fakeuserid").ConfigureAwait(false);

            // assert
            var itemsCollection = fakeCategoriesRepository.CategoryDocuments.Single().Items;

            Assert.AreEqual(1, itemsCollection.Count);
            Assert.IsTrue(
                itemsCollection.Contains(
                    new CategoryItem { Id = "fakeitemid", Preview = "fakepreview", Type = ItemType.Text },
                    new CategoryItemComparer()));
        }

        /// <summary>
        /// Given you have an instance of the category service
        /// And the category service has a category
        /// When you raise the ImageCreated event with the same category id
        /// Then the service should add the category item preview to the category
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task ProcessAddItemEventAsyncAddsImageItem()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(
                new CategoryDocument { Id = "fakecategoryid", Name = "fakename", UserId = "fakeuserid" });
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            var eventToProcess = new EventGridEvent
            {
                Subject = "fakeuserid/fakeitemid",
                EventType = ImageEvents.ImageCreated,
                Data = new ImageCreatedEventData()
                {
                    Category = "fakecategoryid",
                    PreviewUri = new Uri("http://fake/preview.jpg")
                }
            };

            // act
            await service.ProcessAddItemEventAsync(eventToProcess, "fakeuserid").ConfigureAwait(false);

            // assert
            var itemsCollection = fakeCategoriesRepository.CategoryDocuments.Single().Items;

            Assert.AreEqual(1, itemsCollection.Count);
            Assert.IsTrue(
                itemsCollection.Contains(
                    new CategoryItem { Id = "fakeitemid", Preview = "http://fake/preview.jpg", Type = ItemType.Image },
                    new CategoryItemComparer()));
        }

        /// <summary>
        /// Given you have an instance of the category service
        /// And the category service has a category
        /// When you raise the AudioCreated event with the same category id
        /// Then the service should add the category item preview to the category
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task ProcessAddItemEventAsyncAddsAudioItem()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(
                new CategoryDocument { Id = "fakecategoryid", Name = "fakename", UserId = "fakeuserid" });
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            var eventToProcess = new EventGridEvent
            {
                Subject = "fakeuserid/fakeitemid",
                EventType = AudioEvents.AudioCreated,
                Data = new AudioCreatedEventData
                {
                    Category = "fakecategoryid",
                    TranscriptPreview = "faketranscript"
                }
            };

            // act
            await service.ProcessAddItemEventAsync(eventToProcess, "fakeuserid").ConfigureAwait(false);

            // assert
            var itemsCollection = fakeCategoriesRepository.CategoryDocuments.Single().Items;

            Assert.AreEqual(1, itemsCollection.Count);
            Assert.IsTrue(
                itemsCollection.Contains(
                    new CategoryItem { Id = "fakeitemid", Preview = "faketranscript", Type = ItemType.Audio },
                    new CategoryItemComparer()));
        }

        /// <summary>
        /// Given you have an instance of the category service
        /// And the category service has a category
        /// When you raise the ImageCreated event with the same category id
        /// Then the service should publish the CategoryItemsUpdated event.
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task ProcessAddItemEventAsyncPublishesCategoryItemsUpdatedEventToEventGrid()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(
                new CategoryDocument { Id = "fakecategoryid", Name = "fakename", UserId = "fakeuserid" });
            var mockEventGridPublisherService = new Mock<IEventGridPublisherService>();
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                mockEventGridPublisherService.Object);

            var eventToProcess = new EventGridEvent
            {
                Subject = "fakeuserid/fakeitemid",
                EventType = AudioEvents.AudioCreated,
                Data = new AudioCreatedEventData
                {
                    Category = "fakecategoryid",
                    TranscriptPreview = "faketranscript"
                }
            };

            // act
            await service.ProcessAddItemEventAsync(eventToProcess, "fakeuserid").ConfigureAwait(false);

            // assert
            mockEventGridPublisherService.Verify(
                m => m.PostEventGridEventAsync(
                    CategoryEvents.CategoryItemsUpdated,
                    "fakeuserid/fakecategoryid",
                    It.IsAny<CategoryItemsUpdatedEventData>()),
                Times.Once);
        }

        /// <summary>
        /// Given you have an instance of the category service
        /// And the category service has a category
        /// And the category has an audio item preview added to it
        /// When you raise the AudioCreated event with the same audio item id
        /// Then the service should update the preview of the audio item
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task ProcessAddItemEventAsyncUpdatesItemWhenAlreadyExists()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            var category = new CategoryDocument
            {
                Id = "fakecategoryid",
                Name = "fakename",
                UserId = "fakeuserid"
            };
            category.Items.Add(new CategoryItem { Id = "fakeitemid", Preview = "oldpreview" });

            fakeCategoriesRepository.CategoryDocuments.Add(category);

            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            var eventToProcess = new EventGridEvent
            {
                Subject = "fakeuserid/fakeitemid",
                EventType = AudioEvents.AudioCreated,
                Data = new AudioCreatedEventData
                {
                    Category = "fakecategoryid",
                    TranscriptPreview = "newpreview"
                }
            };

            // act
            await service.ProcessAddItemEventAsync(eventToProcess, "fakeuserid").ConfigureAwait(false);

            // assert
            var itemsCollection = fakeCategoriesRepository.CategoryDocuments.Single().Items;

            Assert.AreEqual(1, itemsCollection.Count);
            Assert.IsTrue(
                itemsCollection.Contains(
                    new CategoryItem { Id = "fakeitemid", Preview = "newpreview", Type = ItemType.Audio },
                    new CategoryItemComparer()));
        }

        /// <summary>
        /// Given you have an instance of the category service
        /// And the category service has a category
        /// When you raise the AudioCreated event with the same category id, item id, but different user id
        /// Then the service should not add the category item preview to the category
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task ProcessAddItemEventAsyncDoesNotAddItemWhenUserIdDoesNotMatch()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(
                new CategoryDocument { Id = "fakecategoryid", Name = "fakename", UserId = "fakeuserid1" });
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            var eventToProcess = new EventGridEvent
            {
                Subject = "fakeuserid2/fakeitemid",
                EventType = AudioEvents.AudioCreated,
                Data = new AudioCreatedEventData
                {
                    Category = "fakecategoryid",
                    TranscriptPreview = "newpreview"
                }
            };

            // act
            await service.ProcessAddItemEventAsync(eventToProcess, "fakeuserid2").ConfigureAwait(false);

            // assert
            var itemsCollection = fakeCategoriesRepository.CategoryDocuments.Single().Items;
            Assert.AreEqual(0, itemsCollection.Count);
        }

        /// <summary>
        /// Given you have an instance of the category service
        /// And the category service has a category
        /// When you raise the AudioCreated event that does not have the category id provided
        /// Then the service should throw an Invalid Operation exception
        /// </summary>
        /// <returns>A task to run test.</returns>
        [TestMethod]
        public async Task ProcessAddItemEventAsyncThrowsWhenCategoryNotProvided()
        {
            // arrange
            var fakeCategoriesRepository = new FakeCategoriesRepository();
            fakeCategoriesRepository.CategoryDocuments.Add(new CategoryDocument { Id = "fakecategoryid", Name = "fakename", UserId = "fakeuserid" });
            var service = new CategoriesService(
                fakeCategoriesRepository,
                new Mock<IImageSearchService>().Object,
                new Mock<ISynonymService>().Object,
                new Mock<IEventGridPublisherService>().Object);

            var eventToProcess = new EventGridEvent
            {
                Subject = "fakeuserid/fakeitemid",
                EventType = AudioEvents.AudioCreated,
                Data = new AudioCreatedEventData
                {
                    TranscriptPreview = "faketranscript"
                }
            };

            // act and assert
            await Assert.ThrowsExceptionAsync<InvalidOperationException>(
                () => service.ProcessAddItemEventAsync(eventToProcess, "fakeuserid")).ConfigureAwait(false);
        }

        private class CategoryItemComparer : IEqualityComparer<CategoryItem>
        {
            public bool Equals(CategoryItem x, CategoryItem y) => x.Id == y.Id &&
                                                                  x.Preview == y.Preview &&
                                                                  x.Type == y.Type;

            public int GetHashCode(CategoryItem obj) => obj.GetHashCode();
        }
    }
}
