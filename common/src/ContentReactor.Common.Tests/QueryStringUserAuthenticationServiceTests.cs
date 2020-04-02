namespace ContentReactor.Common.Tests
{
    using System.Threading.Tasks;
    using ContentReactor.Common.UserAuthentication;
    using Microsoft.AspNetCore.Http;
    using Microsoft.AspNetCore.Http.Internal;
    using Microsoft.AspNetCore.Mvc;
    using Xunit;

    public class QueryStringUserAuthenticationServiceTests
    {
        [Fact]
        public async Task GetUserIdValidUserId()
        {
            // arrange
            var req = new DefaultHttpRequest(new DefaultHttpContext())
            {
                QueryString = new QueryString("?userId=fakeuserid"),
            };
            var service = new QueryStringUserAuthenticationService();

            // act
            var result = await service.GetUserIdAsync(req, out var userId, out var responseResult).ConfigureAwait(false);

            // assert
            Assert.True(result);
            Assert.Equal("fakeuserid", userId);
            Assert.Null(responseResult);
        }

        [Fact]
        public async Task GetUserIdDuplicateUserIds()
        {
            // arrange
            var req = new DefaultHttpRequest(new DefaultHttpContext())
            {
                QueryString = new QueryString("?userId=fakeuserid1&userId=fakeuserid2"),
            };
            var service = new QueryStringUserAuthenticationService();

            // act
            var result = await service.GetUserIdAsync(req, out var userId, out var responseResult).ConfigureAwait(false);

            // assert
            Assert.IsType<BadRequestObjectResult>(responseResult);
            Assert.False(result);
            Assert.Null(userId);
        }

        [Fact]
        public async Task GetUserIdNoUserId()
        {
            // arrange
            var req = new DefaultHttpRequest(new DefaultHttpContext())
            {
                QueryString = new QueryString("?otherParameter=xyz"),
            };
            var service = new QueryStringUserAuthenticationService();

            // act
            var result = await service.GetUserIdAsync(req, out var userId, out var responseResult).ConfigureAwait(false);

            // assert
            Assert.IsType<BadRequestObjectResult>(responseResult);
            Assert.False(result);
            Assert.Null(userId);
        }
    }
}
