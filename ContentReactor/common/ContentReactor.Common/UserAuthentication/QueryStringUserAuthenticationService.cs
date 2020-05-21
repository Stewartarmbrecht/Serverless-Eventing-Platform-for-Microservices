namespace ContentReactor.Common.UserAuthentication
{
    using System;
    using System.Linq;
    using System.Threading.Tasks;
    using Microsoft.AspNetCore.Http;
    using Microsoft.AspNetCore.Mvc;

    /// <summary>
    /// User authentication service that uses the query string.
    /// Note: This implementation of the UserAuthentication class uses the query string to obtain the user ID.
    /// This assumes that the APIs are called by trusted clients that have performed user authentication.
    /// An extension to this sample would be to pass the user's identity in using a bearer token through the
    /// Authorization header, and to validate the token and obtain the user ID from a claim.
    /// </summary>
    public class QueryStringUserAuthenticationService : IUserAuthenticationService
    {
        // Note: This implementation of the UserAuthentication class uses the query string to obtain the user ID.
        // This assumes that the APIs are called by trusted clients that have performed user authentication.
        // An extension to this sample would be to pass the user's identity in using a bearer token through the
        // Authorization header, and to validate the token and obtain the user ID from a claim.

        /// <summary>
        /// Gets the user id from query string.
        /// </summary>
        /// <param name="req">Request with the user id in the query string.</param>
        /// <param name="userId">The user id found in the query string.</param>
        /// <param name="responseResult">Null if the user id was successfully retrieved.
        /// Otherwise it will contain a response that explains the failure.</param>
        /// <returns>Boolean value indicating success in retrieving the user Id from the query string.</returns>
        public Task<bool> GetUserIdAsync(HttpRequest req, out string userId, out IActionResult responseResult)
        {
            if (req == null)
            {
                throw new ArgumentNullException(nameof(req));
            }

            // retrieve the user ID parameter from the query string
            var userIdParameter = req.Query
                .SingleOrDefault(q => string.Equals(q.Key, "userId", System.StringComparison.CurrentCultureIgnoreCase))
                .Value;
            if (string.IsNullOrEmpty(userIdParameter) || userIdParameter.Count == 0)
            {
                responseResult = new BadRequestObjectResult(new { error = "Missing mandatory 'userId' parameter in query string." });
                userId = null;
                return Task.FromResult(false);
            }

            if (userIdParameter.Count > 1)
            {
                responseResult = new BadRequestObjectResult(new { error = "Please only specify one 'userId' parameter in query string." });
                userId = null;
                return Task.FromResult(false);
            }

            // we have a valid user ID that we can return
            responseResult = null;
            userId = userIdParameter.Single();
            return Task.FromResult(true);
        }
    }
}
