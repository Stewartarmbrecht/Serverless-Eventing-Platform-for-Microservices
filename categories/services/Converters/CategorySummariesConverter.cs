namespace ContentReactor.Categories.Services.Converters
{
    using System;
    using ContentReactor.Categories.Services.Models.Response;
    using Newtonsoft.Json;

    /// <summary>
    /// Converts an instance of the <see cref="CategorySummaryCollection"/> class to and from json.
    /// </summary>
    public class CategorySummariesConverter : JsonConverter
    {
        /// <summary>
        /// Checks that the provided object can be converted to or from json.
        /// </summary>
        /// <param name="objectType">The type of the object to convert.</param>
        /// <returns>True if the object can be converted.</returns>
        public override bool CanConvert(Type objectType)
        {
            return objectType == typeof(CategorySummaryCollection);
        }

        /// <summary>
        /// Writes the object to the Json writer.
        /// </summary>
        /// <param name="writer">The writer to write the json to.</param>
        /// <param name="value">The object to write.</param>
        /// <param name="serializer">The serializer to use.</param>
        public override void WriteJson(JsonWriter writer, object value, JsonSerializer serializer)
        {
            if (writer == null)
            {
                throw new ArgumentNullException(nameof(writer));
            }

            if (value == null)
            {
                throw new ArgumentNullException(nameof(value));
            }

            if (serializer == null)
            {
                throw new ArgumentNullException(nameof(serializer));
            }

            writer.WriteStartObject();
            foreach (var summary in (CategorySummaryCollection)value)
            {
                writer.WritePropertyName(summary.Id);
                summary.Id = null;
                serializer.Serialize(writer, summary);
            }

            writer.WriteEndObject();
        }

        /// <summary>
        /// Converts json into an instance of a <see cref="CategorySummaryCollection"/> class.
        /// </summary>
        /// <param name="reader">The json reader to use.</param>
        /// <param name="objectType">The type of object to convert to.</param>
        /// <param name="existingValue">The existing object to write the values to.</param>
        /// <param name="serializer">The serializer to use.</param>
        /// <returns>The object passed in with the value updated from the json.</returns>
        public override object ReadJson(JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer)
        {
            throw new NotImplementedException();
        }
    }
}