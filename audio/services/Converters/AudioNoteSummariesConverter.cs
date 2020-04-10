namespace ContentReactor.Audio.Services.Converters
{
    using System;
    using ContentReactor.Audio.Services.Models.Responses;
    using Newtonsoft.Json;

    /// <summary>
    /// Converts an audio note to and from json.
    /// </summary>
    public class AudioNoteSummariesConverter : JsonConverter
    {
        /// <summary>
        /// Checks that the CLR object can be converted.
        /// </summary>
        /// <param name="objectType">The type of the object to convert to an Audio Note Summary.</param>
        /// <returns>True if the object is a <see cref="AudioNoteSummaryCollection"/> type.</returns>
        public override bool CanConvert(Type objectType)
        {
            return objectType == typeof(AudioNoteSummaryCollection);
        }

        /// <summary>
        /// Writes the audio note CLR object to json.
        /// </summary>
        /// <param name="writer">The json writer to write to.</param>
        /// <param name="value">The object that should be written to json.</param>
        /// <param name="serializer">The json serializer to use.</param>
        public override void WriteJson(JsonWriter writer, object value, JsonSerializer serializer)
        {
            if (serializer == null)
            {
                throw new ArgumentNullException(nameof(serializer));
            }

            if (writer == null)
            {
                throw new ArgumentNullException(nameof(writer));
            }

            if (value == null)
            {
                throw new ArgumentNullException(nameof(value));
            }

            writer.WriteStartObject();
            foreach (var summary in (AudioNoteSummaryCollection)value)
            {
                writer.WritePropertyName(summary.Id);
                summary.Id = null;
                serializer.Serialize(writer, summary);
            }

            writer.WriteEndObject();
        }

        /// <summary>
        /// Reads the json into an audio note CLR object.
        /// NOT IMPLEMENTED.
        /// </summary>
        /// <param name="reader">The json reader to use to read the json.</param>
        /// <param name="objectType">The object to read the json to.</param>
        /// <param name="existingValue">The json object that contains the json.</param>
        /// <param name="serializer">The serializer to use.</param>
        /// <returns>The object that was read from the json.</returns>
        public override object ReadJson(JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer)
        {
            throw new NotImplementedException();
        }
    }
}
