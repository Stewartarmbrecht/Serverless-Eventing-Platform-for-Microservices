namespace ContentReactor.Audio.Tests.E2E
{
    using System;
    using System.Collections.Generic;
    using System.Diagnostics.CodeAnalysis;
    using System.Net.Http;
    using System.Threading.Tasks;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Newtonsoft.Json;

    /// <summary>
    /// Contains end to end tests for the Audio API.
    /// </summary>
    [TestClass]
    [TestCategory("E2E")]
    public class CategoriesApiTests
    {
        private static readonly HttpClient HttpClientInstance = new HttpClient();
        private readonly string baseUrl = "http://localhost:7071/api/categories";
        private readonly string defaultUserId = "developer@edentest.com";
        private readonly string defaultCategoryName = "Test";

        /// <summary>
        /// Given you have a valid user id
        /// When you add a new category for that user id
        /// Then you 
        /// </summary>
        /// <returns>Task for running the test.</returns>
        [TestMethod]
        public async Task AddCategoryWithSuccess()
        {
            var categoryId = await this.AddCategory().ConfigureAwait(false);
            Assert.IsNotNull(categoryId);

            ContentReactor.Categories.Services.Models.Response.CategoryDetails newCategory =
                await this.GetCategory(categoryId).ConfigureAwait(false);

            Assert.IsNotNull(newCategory);
            Assert.AreEqual(this.defaultCategoryName, newCategory.Name);
            Assert.AreEqual(categoryId, newCategory.Id);
            Assert.AreEqual(0, newCategory.Items.Count);
            var count = 0;
            ContentReactor.Categories.Services.Models.Response.CategoryDetails category = null;
            while (count < 5)
            {
                category = await this.GetCategory(categoryId).ConfigureAwait(false);
                if (category.ImageUrl != null && category.Synonyms != null)
                {
                    count = 5;
                }

                count++;

                if (count > 0)
                {
                    System.Threading.Thread.Sleep(1000);
                }
            }

            Assert.IsTrue(category.Synonyms.Count > 0);
            Assert.IsNotNull(category.ImageUrl);

        }

        [SuppressMessage("StyleCop.CSharp.SpacingRules", "SA1009:ClosingParenthesisMustBeSpacedCorrectly", Justification = "Reviewed.")]
        private async Task<string> AddCategory(string userId = null)
        {
            CreateCategoryRequest req = new CreateCategoryRequest()
            {
                Name = this.defaultCategoryName
            };
            var reqContent = JsonConvert.SerializeObject(req);
            userId ??= this.defaultUserId;
            Uri postUri = new Uri($"{this.baseUrl}?userId={userId}");
            var beginAddResponse = await HttpClientInstance.PostAsync(postUri, new StringContent(reqContent)).ConfigureAwait(false);
            var beginAddResponseContent = await beginAddResponse.Content.ReadAsStringAsync().ConfigureAwait(false);
            dynamic beginAddResult = JsonConvert.DeserializeObject(beginAddResponseContent);
            var categoryId = (string)beginAddResult.id;
            return categoryId;
        }

        private async Task<CategoryDetails> GetCategory(string categoryId, string userId = null)
        {
            userId ??= this.defaultUserId;
            Uri uri = new Uri($"{this.baseUrl}/{categoryId}?userId={userId}");
            var beginAddResponse = await HttpClientInstance.GetAsync(uri).ConfigureAwait(false);
            var beginAddResponseContent = await beginAddResponse.Content.ReadAsStringAsync().ConfigureAwait(false);
            CategoryDetails categoryDetails = JsonConvert.DeserializeObject<CategoryDetails>(beginAddResponseContent);
            return categoryDetails;
        }
    }
}
