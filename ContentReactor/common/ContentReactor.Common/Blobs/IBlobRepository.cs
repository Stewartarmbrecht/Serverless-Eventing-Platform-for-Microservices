namespace ContentReactor.Common.Blobs
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Threading.Tasks;
    using Azure.Storage;
    using Azure.Storage.Blobs;
    using Azure.Storage.Blobs.Models;

    /// <summary>
    /// Interface interacting with blobs.
    /// </summary>
    public interface IBlobRepository
    {
        /// <summary>
        /// Gets a URI that can be used to upload a specific blob to the blob container.
        /// </summary>
        /// <param name="containerName">Name of the container to upload the blob to.</param>
        /// <param name="blobName">Name of the blob.</param>
        /// <returns>Uri to the blob that includes the shared access key.</returns>
        Task<Uri> GetBlobUploadUrlAsync(string containerName, string blobName);

        /// <summary>
        /// Gets a URI that can be used to download a specific blob to the blob container.
        /// </summary>
        /// <param name="blob">The blob to get the download url for.</param>
        /// <returns>Uri to the blob that includes the shared access key.</returns>
        Uri GetBlobDownloadUrl(Blob blob);

        /// <summary>
        /// Gets the details of a single blob.
        /// </summary>
        /// <param name="containerName">Name of the container for the blob.</param>
        /// <param name="blobName">Name of the blob.</param>
        /// <returns>BlobClient.</returns>
        Task<Blob> GetBlobAsync(string containerName, string blobName);

        /// <summary>
        /// Downloads a blob to a stream.
        /// </summary>
        /// <param name="containerName">Name of the container for the blob.</param>
        /// <param name="blobName">Name of the blob.</param>
        /// <param name="stream">The stream to copy the blob to.</param>
        /// <returns>A task for the work.</returns>
        Task CopyBlobToStreamAsync(string containerName, string blobName, Stream stream);

        /// <summary>
        /// Updates the properties of a blob.
        /// </summary>
        /// <param name="blob">The blob with the updated properties.</param>
        /// <returns>Task for performing the operation asynchronously.</returns>
        Task UpdateBlobPropertiesAsync(Blob blob);

        /// <summary>
        /// Lists all the blobs in a folder.
        /// </summary>
        /// <param name="containerName">Name of the container holding the blobs to list.</param>
        /// <param name="prefix">Name of the prefix to filter the list of blobs by.</param>
        /// <returns>List of BlobItems.</returns>
        Task<IList<Blob>> ListBlobsInFolderAsync(string containerName, string prefix);

        /// <summary>
        /// Deletes a blob.
        /// </summary>
        /// <param name="containerName">Container that holds the blob.</param>
        /// <param name="blobName">Name of the blob to delete..</param>
        /// <returns>Task for deleting the blob.</returns>
        Task DeleteBlobAsync(string containerName, string blobName);
    }
}
