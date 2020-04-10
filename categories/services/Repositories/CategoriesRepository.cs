namespace ContentReactor.Categories.Services.Repositories
{
    using System;
    using System.Linq;
    using System.Net;
    using System.Threading.Tasks;
    using ContentReactor.Categories.Services.Models;
    using ContentReactor.Categories.Services.Models.Data;
    using ContentReactor.Categories.Services.Models.Response;
    using ContentReactor.Categories.Services.Models.Results;
    using Microsoft.Azure.Documents;
    using Microsoft.Azure.Documents.Client;
    using Microsoft.Azure.Documents.Linq;

    /// <summary>
    /// Intefaces with the category storage.
    /// </summary>
    public class CategoriesRepository : ICategoriesRepository
    {
        private static readonly string EndpointUrl = Environment.GetEnvironmentVariable("CosmosDbAccountEndpointUrl");
        private static readonly string AccountKey = Environment.GetEnvironmentVariable("CosmosDbAccountKey");
        private static readonly string DatabaseName = Environment.GetEnvironmentVariable("DatabaseName");
        private static readonly string CollectionName = Environment.GetEnvironmentVariable("CollectionName");
        private static readonly DocumentClient DocumentClient = new DocumentClient(new Uri(EndpointUrl), AccountKey);

        /// <summary>
        /// Adds a new cagtegory.
        /// </summary>
        /// <param name="categoryDocument">The document representation of the category.</param>
        /// <returns>The id of the category.</returns>
        public async Task<string> AddCategoryAsync(CategoryDocument categoryDocument)
        {
            var documentUri = UriFactory.CreateDocumentCollectionUri(DatabaseName, CollectionName);
            Document doc = await DocumentClient.CreateDocumentAsync(documentUri, categoryDocument).ConfigureAwait(false);
            return doc.Id;
        }

        /// <summary>
        /// Deletes a category.
        /// </summary>
        /// <param name="categoryId">The Id of the category to delete.</param>
        /// <param name="userId">The id of the user that owns the category.</param>
        /// <returns>The results of the delete operation.</returns>
        public async Task<DeleteCategoryResult> DeleteCategoryAsync(string categoryId, string userId)
        {
            var documentUri = UriFactory.CreateDocumentUri(DatabaseName, CollectionName, categoryId);
            try
            {
                await DocumentClient.DeleteDocumentAsync(documentUri, new RequestOptions { PartitionKey = new PartitionKey(userId) }).ConfigureAwait(false);
                return DeleteCategoryResult.Success;
            }
            catch (DocumentClientException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
            {
                // we return the NotFound result to indicate the document was not found
                return DeleteCategoryResult.NotFound;
            }
        }

        /// <summary>
        /// Updates a category.
        /// </summary>
        /// <param name="categoryDocument">The category details to update.</param>
        /// <returns>The results of the category update.</returns>
        public async Task<UpdateCategoryResult> UpdateCategoryAsync(CategoryDocument categoryDocument)
        {
            if (categoryDocument == null)
            {
                throw new ArgumentNullException(nameof(categoryDocument));
            }

            var documentUri = UriFactory.CreateDocumentUri(DatabaseName, CollectionName, categoryDocument.Id);
            var concurrencyCondition = new AccessCondition
            {
                Condition = categoryDocument.ETag,
                Type = AccessConditionType.IfMatch,
            };
            var document = await DocumentClient.ReplaceDocumentAsync(documentUri, categoryDocument, new RequestOptions { AccessCondition = concurrencyCondition }).ConfigureAwait(false);

            if (document.StatusCode == System.Net.HttpStatusCode.OK)
            {
                return UpdateCategoryResult.Success;
            }

            return UpdateCategoryResult.NotFound;
        }

        /// <summary>
        /// Gets the details of a single category.
        /// </summary>
        /// <param name="categoryId">The id of the category to retrieve.</param>
        /// <param name="userId">The user id that owns the category.</param>
        /// <returns>The category document. An instance of the <see cref="CategoryDocument"/> class.</returns>
        public async Task<CategoryDocument> GetCategoryAsync(string categoryId, string userId)
        {
            var documentUri = UriFactory.CreateDocumentUri(DatabaseName, CollectionName, categoryId);
            try
            {
                var documentResponse = await DocumentClient.ReadDocumentAsync<CategoryDocument>(
                    documentUri,
                    new RequestOptions
                    {
                        PartitionKey = new PartitionKey(userId),
                    }).ConfigureAwait(false);
                return documentResponse.Document;
            }
            catch (DocumentClientException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
            {
                // we return null to indicate the document was not found
                return null;
            }
        }

        /// <summary>
        /// Gets a list of categories.
        /// </summary>
        /// <param name="itemId">The id of the item to get the category for.</param>
        /// <param name="itemType">The type of item.</param>
        /// <param name="userId">The id of the user the item is uploaded to.</param>
        /// <returns>Collection of category summaries.</returns>
        public async Task<CategoryDocument> FindCategoryWithItemAsync(string itemId, ItemType itemType, string userId)
        {
            var documentUri = UriFactory.CreateDocumentCollectionUri(DatabaseName, CollectionName);

            // create a query to find the category with this item in it
            const string sqlQuery = "SELECT * FROM c WHERE c.userId = @userId AND ARRAY_CONTAINS(c.items, { id: @itemId, type: @itemType }, true)";
            var sqlParameters = new SqlParameterCollection
            {
                new SqlParameter("@userId", userId),
                new SqlParameter("@itemId", itemId),
                new SqlParameter("@itemType", itemType.ToString()),
            };
            var query = DocumentClient
                .CreateDocumentQuery<CategoryDocument>(documentUri, new SqlQuerySpec(sqlQuery, sqlParameters))
                .AsDocumentQuery();

            // execute the query
            var response = await query.ExecuteNextAsync<CategoryDocument>().ConfigureAwait(false);
            return response.SingleOrDefault();
        }

        /// <summary>
        /// Gets the list of categories for a single user.
        /// </summary>
        /// <param name="userId">The user id that owns the category.</param>
        /// <returns>A Collection of Category summaries. An instance of the <see cref="CategorySummaryCollection"/> class.</returns>
        public async Task<CategorySummaryCollection> ListCategoriesAsync(string userId)
        {
            var documentUri = UriFactory.CreateDocumentCollectionUri(DatabaseName, CollectionName);

            // create a query to just get the document ids
            var query = DocumentClient
                .CreateDocumentQuery<CategoryDocument>(documentUri)
                .Where(d => d.UserId == userId)
                .Select(d => new CategorySummary { Id = d.Id, Name = d.Name })
                .AsDocumentQuery();

            // iterate until we have all of the ids
            var list = new CategorySummaryCollection();

            while (query.HasMoreResults)
            {
                var summaries = await query.ExecuteNextAsync<CategorySummary>().ConfigureAwait(false);
                list.AddRange(summaries);
            }

            return list;
        }
    }
}
