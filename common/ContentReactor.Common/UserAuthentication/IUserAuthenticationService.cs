namespace ContentReactor.Common.UserAuthentication
{
    using System.Threading.Tasks;
    using Microsoft.AspNetCore.Http;
    using Microsoft.AspNetCore.Mvc;

    /// <summary>
    /// Interface for authenticating the user for the http request.
    /// </summary>
    public interface IUserAuthenticationService
    {
        /// <summary>
        /// Gets the user id from query string.
        /// </summary>
        /// <param name="req">Request with the user id in the query string.</param>
        /// <param name="userId">The user id found in the query string.</param>
        /// <param name="responseResult">Null if the user id was successfully retrieved.
        /// Otherwise it will contain a response that explains the failure.</param>
        /// <returns>Boolean value indicating success in retrieving the user Id from the query string.</returns>
        Task<bool> GetUserIdAsync(HttpRequest req, out string userId, out IActionResult responseResult);
    }
}