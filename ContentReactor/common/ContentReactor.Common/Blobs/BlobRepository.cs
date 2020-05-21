namespace ContentReactor.Common.Blobs
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Threading.Tasks;
    using Azure.Storage;
    using Azure.Storage.Blobs;
    using Azure.Storage.Blobs.Models;
    using Azure.Storage.Sas;

    /// <summary>
    /// Provides an interface for interacting with a blob container.
    /// </summary>
    public class BlobRepository : IBlobRepository
    {
        /// <summary>
        /// Connection string for the target blob repository.
        /// </summary>
        /// <returns>Connection string.</returns>
        private static readonly string BlobConnectionString = Environment.GetEnvironmentVariable("BlobConnectionString");

        private static readonly string BlobAccountKey = Environment.GetEnvironmentVariable("BlobAccountKey");

        /// <summary>
        /// Gets a URI that can be used to upload a specific blob to the blob container.
        /// </summary>
        /// <param name="containerName">Name of the container to upload the blob to.</param>
        /// <param name="blobName">Name of the blob.</param>
        /// <returns>Uri to the blob that includes the shared access key.</returns>
        public async Task<Uri> GetBlobUploadUrlAsync(string containerName, string blobName)
        {
            // Create container client using connection string and passed in container name.
            var containerClient = new BlobContainerClient(BlobConnectionString, containerName);

            // Create the container if it does not exist.
            await containerClient.CreateIfNotExistsAsync().ConfigureAwait(false);

            // Create a storage shared key to use to create a shared access signature.
            StorageSharedKeyCredential credential = new StorageSharedKeyCredential(containerClient.AccountName, BlobAccountKey);

            // Create a blob client for the blob.
            BlobClient blobClient = containerClient.GetBlobClient(blobName);

            // Create a service level shared access signature that only allows uploading the blob to azure blob service.
            BlobSasBuilder sas = new BlobSasBuilder
            {
                BlobContainerName = containerName,
                BlobName = blobName,
                ExpiresOn = DateTime.UtcNow.AddMinutes(10),
            };

            // Allow read access
            sas.SetPermissions(BlobSasPermissions.Write);

            // Create a shared access signature query paramater to add to the URI that will enable the file upload.
            string sasToken = sas.ToSasQueryParameters(credential).ToString();

            // Construct the full URI, including the SAS token.
            UriBuilder fullUri = new UriBuilder()
            {
                Scheme = "https",
                Host = string.Format(System.Globalization.CultureInfo.CurrentCulture, "{0}.blob.core.windows.net", blobClient.AccountName),
                Path = string.Format(System.Globalization.CultureInfo.CurrentCulture, "{0}/{1}", blobClient.BlobContainerName, blobClient.Name),
                Query = sasToken,
            };

            return fullUri.Uri;
        }

        /// <summary>
        /// Gets a URI that can be used to download a specific blob to the blob container.
        /// </summary>
        /// <param name="blob">The blob to get the download Url for.</param>
        /// <returns>Uri to the blob that includes the shared access key for downloading the blob.</returns>
        public Uri GetBlobDownloadUrl(Blob blob)
        {
            if (blob == null)
            {
                throw new ArgumentNullException(nameof(blob));
            }

            // Create a storage shared key to use to create a shared access signature.
            StorageSharedKeyCredential credential = new StorageSharedKeyCredential(blob.AccountName, BlobAccountKey);

            // Create a service level shared access signature that only allows uploading the blob to azure blob service.
            AccountSasBuilder sas = new AccountSasBuilder
            {
                // Allow access to blobs.
                Services = AccountSasServices.Blobs,

                // Allow access to the service level APIs.
                ResourceTypes = AccountSasResourceTypes.Service,

                // Access expires in 1 hour!
                ExpiresOn = DateTimeOffset.UtcNow.AddHours(1),
            };

            // Allow read access
            sas.SetPermissions(AccountSasPermissions.Read);

            // Create a shared access signature query paramater to add to the URI that will enable the file upload.
            string sasToken = sas.ToSasQueryParameters(credential).ToString();

            // Construct the full URI, including the SAS token.
            UriBuilder fullUri = new UriBuilder()
            {
                Scheme = "https",
                Host = string.Format(System.Globalization.CultureInfo.CurrentCulture, "{0}.blob.core.windows.net", blob.AccountName),
                Path = string.Format(System.Globalization.CultureInfo.CurrentCulture, "{0}/{1}", blob.ContainerName, blob.BlobName),
                Query = sasToken,
            };

            return fullUri.Uri;
        }

        /// <summary>
        /// Gets a blob client for a single blob.
        /// </summary>
        /// <param name="containerName">Name of the container for the blob.</param>
        /// <param name="blobName">Name of the blob.</param>
        /// <returns>The <see cref="Blob"/> that contains the properties about the blob.</returns>
        public async Task<Blob> GetBlobAsync(string containerName, string blobName)
        {
            var containerClient = new BlobContainerClient(BlobConnectionString, containerName);
            var blobClient = containerClient.GetBlobClient(blobName);

            var blobExists = await blobClient.ExistsAsync().ConfigureAwait(false);
            if (!blobExists)
            {
                return null;
            }

            var blobProperties = await blobClient.GetPropertiesAsync().ConfigureAwait(false);

            return new Blob(containerClient.AccountName, containerName, blobName, blobProperties.Value.Metadata);
        }

        /// <summary>
        /// Downloads a blob to a stream.
        /// </summary>
        /// <param name="containerName">Name of the container for the blob.</param>
        /// <param name="blobName">Name of the blob.</param>
        /// <param name="stream">The stream to copy the blob to.</param>
        /// <returns>A task for the work.</returns>
        public async Task CopyBlobToStreamAsync(string containerName, string blobName, Stream stream)
        {
            var containerClient = new BlobContainerClient(BlobConnectionString, containerName);
            var blobClient = containerClient.GetBlobClient(blobName);

            await blobClient.DownloadToAsync(stream).ConfigureAwait(false);

            return;
        }

        /// <summary>
        /// Updates the properties of a blob.
        /// </summary>
        /// <param name="blob">The blob with the updated properties.</param>
        /// <returns>Task for performing the operation asynchronously.</returns>
        public async Task UpdateBlobPropertiesAsync(Blob blob)
        {
            if (blob == null)
            {
                throw new ArgumentNullException(nameof(blob));
            }

            var containerClient = new BlobContainerClient(BlobConnectionString, blob.ContainerName);
            var blobClient = containerClient.GetBlobClient(blob.BlobName);

            var blobExists = await blobClient.ExistsAsync().ConfigureAwait(false);
            if (!blobExists)
            {
                return;
            }

            await blobClient.SetMetadataAsync(blob.Properties).ConfigureAwait(false);
        }

        /// <summary>
        /// Lists all the blobs in a folder.
        /// </summary>
        /// <param name="containerName">Name of the container holding the blobs to list.</param>
        /// <param name="prefix">Name of the prefix to filter the list of blobs by.</param>
        /// <returns>List of <see cref="Blob"/> whose name starts with the prefix.</returns>
        public async Task<IList<Blob>> ListBlobsInFolderAsync(string containerName, string prefix)
        {
            var containerClient = new BlobContainerClient(BlobConnectionString, containerName);
            await containerClient.CreateIfNotExistsAsync().ConfigureAwait(false);

            // list all blobs in folder
            var blobsInFolder = new List<Blob>();
            await foreach (BlobItem blob in containerClient.GetBlobsAsync(default, default, prefix, default))
            {
                blobsInFolder.Add(new Blob(containerClient.AccountName, containerName, blob.Name, new Dictionary<string, string>()));
            }

            return blobsInFolder;
        }

        /// <summary>
        /// Deletes a blob.
        /// </summary>
        /// <param name="containerName">Container that holds the blob.</param>
        /// <param name="blobName">Name of the blob to delete.</param>
        /// <returns>Task for deleting the blob.</returns>
        public async Task DeleteBlobAsync(string containerName, string blobName)
        {
            var containerClient = new BlobContainerClient(BlobConnectionString, containerName);
            var blobClient = containerClient.GetBlobClient(blobName);
            await blobClient.DeleteIfExistsAsync().ConfigureAwait(false);
        }
    }
}
