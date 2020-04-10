namespace ContentReactor.Categories.Services
{
    using System;
    using System.Threading.Tasks;

    /// <summary>
    /// Provides service to get an image for a term using bing image search.
    /// </summary>
    public interface IImageSearchService
    {
        /// <summary>
        /// Gets the url to a random image returned in the search results for a term using the Cognitive Services search api.
        /// </summary>
        /// <param name="searchTerm">The search term to find a image for.</param>
        /// <returns>The url to the image.</returns>
        Task<Uri> FindImageUrlAsync(string searchTerm);
    }
}
