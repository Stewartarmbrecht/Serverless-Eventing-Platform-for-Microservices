using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using ContentReactor.Web.Server.Models;
using ContentReactor.Web.Server.Services;

namespace ContentReactor.Web.Server.Controllers
{
    /// <summary>
    /// Notification service called by the event grid for subscribed events.  
    /// See the ./deploy/eventGridSubscriptions-web.json for the event subscriptions.
    /// </summary>
    [Produces("application/json")]
    [Route("api/[controller]")]
    public class CategoryNotificationController : Controller
    {
        private readonly INotificationService _notificationService;
        public CategoryNotificationController(INotificationService notificationService)
        {
            _notificationService = notificationService;
        }

        // POST: api/CategoryNotification
        [HttpPost]
        public IActionResult Post([FromBody] IList<CategoryEventData> e)
        {
            return _notificationService.HandleCategoryNotification(e);
        }
    }
}