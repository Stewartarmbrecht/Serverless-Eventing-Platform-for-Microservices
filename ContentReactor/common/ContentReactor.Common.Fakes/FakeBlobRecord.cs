namespace ContentReactor.Common.Fakes
{
    using System.IO;
    using ContentReactor.Common.Blobs;

    /// <summary>
    /// Fake blob record for testing.
    /// </summary>
    public class FakeBlobRecord
    {
        /// <summary>
        /// Gets or sets the container name for the blob record.
        /// </summary>
        /// <value>String.</value>
        public string ContainerName { get; set; }

        /// <summary>
        /// Gets or sets the id of the blob.
        /// </summary>
        /// <value>String.</value>
        public string BlobId { get; set; }

        /// <summary>
        /// Gets or sets the blob client for the record.
        /// </summary>
        /// <value>BlobClient.</value>
        public Blob Blob { get; set; }

        /// <summary>
        /// Gets or sets the content type of the blob.
        /// </summary>
        /// <value>String.</value>
        public string ContentType { get; set; }

        /// <summary>
        /// Gets or sets the stream for the blob.
        /// </summary>
        /// <value>The stream that contais the blob.</value>
        public Stream Stream { get; set; }
    }
}
