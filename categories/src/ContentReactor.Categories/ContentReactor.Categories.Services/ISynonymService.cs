namespace ContentReactor.Categories.Services
{
    using System.Collections.Generic;
    using System.Threading.Tasks;

    /// <summary>
    /// Interface for accessing the Synonym service.
    /// </summary>
    public interface ISynonymService
    {
        /// <summary>
        /// Gets a list of synonyms for a search term.
        /// </summary>
        /// <param name="searchTerm">The search term to find synonyms for.</param>
        /// <returns>The list of synonyms.</returns>
        Task<IList<string>> GetSynonymsAsync(string searchTerm);
    }
}