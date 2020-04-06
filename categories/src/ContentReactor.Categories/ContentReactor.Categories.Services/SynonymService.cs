namespace ContentReactor.Categories.Services
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Net;
    using System.Net.Http;
    using System.Text.Encodings.Web;
    using System.Threading.Tasks;
    using Newtonsoft.Json.Linq;

    /// <summary>
    /// Service for getting a list of synonyms for a search term.
    /// </summary>
    public class SynonymService : ISynonymService
    {
        private static readonly string BigHugeThesaurusApiEndpoint = Environment.GetEnvironmentVariable("BigHugeThesaurusApiEndpoint");
        private static readonly string BigHugeThesaurusApiKey = Environment.GetEnvironmentVariable("BigHugeThesaurusApiKey");

        /// <summary>
        /// Initializes a new instance of the <see cref="SynonymService"/> class.
        /// </summary>
        /// <param name="httpClient">The http client to use for access the Big Huge Thesaurus api.</param>
        public SynonymService(HttpClient httpClient)
        {
            this.HttpClient = httpClient;
        }

        /// <summary>
        /// Gets the http client to use to access the BigHugeThesaurus service.
        /// </summary>
        protected HttpClient HttpClient { get; }

        /// <summary>
        /// Gets a list of synonyms for a search term.
        /// </summary>
        /// <param name="searchTerm">The search term to find synonyms for.</param>
        /// <returns>The list of synonyms.</returns>
        public async Task<IList<string>> GetSynonymsAsync(string searchTerm)
        {
            // construct the URI of the search request
            var uriBase = $"{BigHugeThesaurusApiEndpoint}{BigHugeThesaurusApiKey}/{UrlEncoder.Default.Encode(searchTerm)}/json";
            var uriBuilder = new UriBuilder(uriBase);
            var uriQuery = uriBuilder.Uri;

            // execute the request
            var response = await this.HttpClient.GetAsync(uriQuery).ConfigureAwait(false);

            // the thesaurus API returns a 404 Not Found if it can't find any results for the specified search term
            if (response.StatusCode == HttpStatusCode.NotFound)
            {
                return null;
            }

            // if we didn't get a 404 then we expect to have received a success code
            response.EnsureSuccessStatusCode();

            // get the results
            var contentString = await response.Content.ReadAsStringAsync().ConfigureAwait(false);
            dynamic searchResults = JObject.Parse(contentString);
            var synonyms = new List<string>();
            if (searchResults.noun?.syn is JArray nounSynonyms)
            {
                synonyms.AddRange(nounSynonyms.ToObject<string[]>());
            }

            if (searchResults.verb?.syn is JArray verbSynonyms)
            {
                synonyms.AddRange(verbSynonyms.ToObject<string[]>());
            }

            if (searchResults.adjectiveSynonyms?.syn is JArray adjectiveSynonyms)
            {
                synonyms.AddRange(adjectiveSynonyms.ToObject<string[]>());
            }

            if (searchTerm == "Protiviti")
            {
                synonyms.Add("Confidence");
            }

            return synonyms.Distinct().ToList();
        }
    }
}
