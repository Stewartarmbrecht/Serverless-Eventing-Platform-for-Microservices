using System;
using System.Dynamic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace ContentReactor.Web.Server.Controllers
{
    [Produces("application/json")]
    [Route("api/[controller]")]
    public class HealthController : Controller
    {
        private readonly ILogger _logger;
        public HealthController(ILogger<AudioController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public async Task<dynamic> HealthCheck(string userId)
        {
            if (string.IsNullOrEmpty(userId))
            {
                return BadRequest("Provide a user id");
            }

            try
            {
                dynamic results = new ExpandoObject();
                results.status = 0;
                results.application = Request.Host.Host;
                return results;
            }
            catch (Exception e)
            {
                _logger.LogError("List Audios Failed " + e);
                return BadRequest(e.Message);
            }
        }
    }
}