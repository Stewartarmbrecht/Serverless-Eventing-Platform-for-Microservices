using System;
using ContentReactor.Categories.Services;
using ContentReactor.Categories.Services.Repositories;
using ContentReactor.Common;
using ContentReactor.Common.UserAuthentication;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Http;
using Microsoft.Extensions.Logging;

[assembly: FunctionsStartup(typeof(ContentReactor.Categories.Api.Startup))]

namespace ContentReactor.Categories.Api
{
    /// <summary>
    /// Initialized at that startup of the function.
    /// </summary>
    public class Startup : FunctionsStartup
    {
        /// <summary>
        /// Configures services for the function.
        /// </summary>
        /// <param name="builder">The <see cref="IFunctionsHostBuilder"/> instance that providers access to building in services.</param>
        public override void Configure(IFunctionsHostBuilder builder)
        {
            if (builder == null)
            {
                throw new ArgumentNullException(nameof(builder));
            }

            builder.Services.AddLocalization(opts => opts.ResourcesPath = "Resources");
            builder.Services.AddHttpClient();

            builder.Services.AddSingleton<ICategoriesRepository, CategoriesRepository>();
            builder.Services.AddSingleton<IImageSearchService, ImageSearchService>();
            builder.Services.AddSingleton<ISynonymService, SynonymService>();
            builder.Services.AddSingleton<IEventGridPublisherService, EventGridPublisherService>();
            builder.Services.AddSingleton<IEventGridSubscriberService, EventGridSubscriberService>();
            builder.Services.AddSingleton<ICategoriesService, CategoriesService>();
            builder.Services.AddSingleton<IUserAuthenticationService, QueryStringUserAuthenticationService>();
        }
    }
}