namespace ContentReactor.Common.Tests
{
    using Xunit;

    public class StringExtensionsTests
    {
        [Fact]
        public void TruncateReturnsShortString()
        {
            // arrange
            const string originalString = "short string should be returned as-is";

            // act
            var result = originalString.Truncate(100);

            // assert
            Assert.Equal(originalString, result);
        }

        [Fact]
        public void TruncateReturnsShortStringWhenEqualToMaximumLength()
        {
            // arrange
            const string originalString = "a longer string should be truncated";

            // act
            var result = originalString.Truncate(originalString.Length);

            // assert
            Assert.Equal(originalString, result);
        }

        [Fact]
        public void TruncateReturnsShortenedVersionOfLongString()
        {
            // arrange
            const string originalString = "a longer string should be truncated";

            // act
            var result = originalString.Truncate(10);

            // assert
            Assert.Equal("a longe...", result);
        }
    }
}
