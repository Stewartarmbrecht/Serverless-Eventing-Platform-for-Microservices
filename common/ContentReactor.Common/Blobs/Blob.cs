namespace ContentReactor.Common.Blobs
{
    using System.Collections.Generic;

    /// <summary>
    /// Provides the details of a single blob.
    /// </summary>
    public class Blob
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="Blob"/> class.
        /// </summary>
        /// <param name="accountName">The name of the account storing the blob.</param>
        /// <param name="containerName">The name of the container storing the blob.</param>
        /// <param name="blobName">The unique name of the blob in the container.</param>
        /// <param name="properties">The properites colletion for the blob.</param>
        public Blob(
            string accountName,
            string containerName,
            string blobName,
            IDictionary<string, string> properties = null)
        {
            this.AccountName = accountName;
            this.ContainerName = containerName;
            this.BlobName = blobName;
            if (properties == null)
            {
                properties = new Dictionary<string, string>();
            }

            this.Properties = properties;
        }

        /// <summary>
        /// Gets the account name the blob is stored in.
        /// </summary>
        /// <value>The name of the account that stores the blob.</value>
        public string AccountName { get; }

        /// <summary>
        /// Gets the container name the blob is stored in.
        /// </summary>
        /// <value>The name of the container that stores the blob.</value>
        public string ContainerName { get; }

        /// <summary>
        /// Gets the name of the blob.
        /// </summary>
        /// <value>The name of the folder that stores the blob.</value>
        public string BlobName { get; }

        /// <summary>
        /// Gets the properties for the blob.
        /// </summary>
        /// <value>String dictionary that contains all properties of the blob.</value>
        public IDictionary<string, string> Properties { get; }
    }
}
