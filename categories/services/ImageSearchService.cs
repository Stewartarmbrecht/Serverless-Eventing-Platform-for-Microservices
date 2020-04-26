namespace ContentReactor.Categories.Services
{
    using System;
    using System.Net.Http;
    using System.Threading.Tasks;
    using System.Web;
    using Newtonsoft.Json.Linq;

    /// <summary>
    /// Provides service to get an image for a term using bing image search.
    /// </summary>
    public class ImageSearchService : IImageSearchService
    {
        private static readonly string CognitiveServicesSearchApiEndpoint = Environment.GetEnvironmentVariable("CognitiveServicesSearchApiEndpoint");
        private static readonly string CognitiveServicesSearchApiKey = Environment.GetEnvironmentVariable("CognitiveServicesSearchApiKey");

        /// <summary>
        /// Initializes a new instance of the <see cref="ImageSearchService"/> class.
        /// </summary>
        /// <param name="httpClient">The http client to use.</param>
        public ImageSearchService(HttpClient httpClient)
        {
            this.Random = new Random();
            this.HttpClient = httpClient;
        }

        /// <summary>
        /// Gets the http client to use to access the Cognitive Services search api.
        /// </summary>
        /// <value>The http client.</value>
        protected HttpClient HttpClient { get; }

        /// <summary>
        /// Gets the Random number generator to use to find an image in the search results.
        /// </summary>
        /// <value>The random number generator.</value>
        protected Random Random { get; }

        /// <summary>
        /// Gets the url to a random image returned in the search results for a term using the Cognitive Services search api.
        /// </summary>
        /// <param name="searchTerm">The search term to find a image for.</param>
        /// <returns>The url to the image.</returns>
        public async Task<Uri> FindImageUrlAsync(string searchTerm)
        {
            this.HttpClient.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", CognitiveServicesSearchApiKey);

            // construct the URI of the search request
            var uriBuilder = new UriBuilder(CognitiveServicesSearchApiEndpoint);
            var query = HttpUtility.ParseQueryString(uriBuilder.Query);
            query["q"] = searchTerm;
            uriBuilder.Query = query.ToString();
            var uriQuery = uriBuilder.Uri;

            // execute the request
            var response = await this.HttpClient.GetAsync(uriQuery).ConfigureAwait(false);
            response.EnsureSuccessStatusCode();

            // get the results
            var contentString = await response.Content.ReadAsStringAsync().ConfigureAwait(false);
            dynamic responseJson = JObject.Parse(contentString);
            var results = (JArray)responseJson.value;
            if (results.Count == 0)
            {
                return null;
            }

            // pick a random result
            var index = this.Random.Next(0, results.Count - 1);
            var topResult = (dynamic)results[index];
            return topResult.contentUrl;
        }
    }
}
