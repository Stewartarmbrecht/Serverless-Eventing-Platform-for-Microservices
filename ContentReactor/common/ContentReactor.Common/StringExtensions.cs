namespace ContentReactor.Common
{
    /// <summary>
    /// Extension methods for strings.
    /// </summary>
    public static class StringExtensions
    {
        /// <summary>
        /// Truncates a string over the maximum length and adds '...' to the end.
        /// </summary>
        /// <param name="value">Value to truncate.</param>
        /// <param name="maximumLength">Length at which to truncate the text.</param>
        /// <param name="continuationMarker">The marker to place at the end of the string to indicate text was truncated.</param>
        /// <returns>Truncated string.</returns>
        public static string Truncate(this string value, int maximumLength, string continuationMarker = "...")
        {
            if (continuationMarker == null)
            {
                throw new System.ArgumentNullException(nameof(continuationMarker));
            }

            if (string.IsNullOrEmpty(value) || (value.Length <= maximumLength))
            {
                return value;
            }

            var truncatedString = value.Substring(0, maximumLength - continuationMarker.Length);
            return truncatedString + continuationMarker;
        }
    }
}
