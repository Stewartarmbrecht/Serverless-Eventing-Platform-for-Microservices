namespace ContentReactor.Common.Fakes
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using System.Threading.Tasks;
    using ContentReactor.Common.Blobs;

    /// <summary>
    /// Fake blob repository for testing.
    /// </summary>
    public class FakeBlobRepository : IBlobRepository
    {
        /// <summary>
        /// Fake name of the blob storage account.
        /// </summary>
        private const string AccountName = "fakeblobaccount";

        /// <summary>
        /// Initializes a new instance of the <see cref="FakeBlobRepository"/> class.
        /// </summary>
        public FakeBlobRepository()
        {
            this.Blobs = new List<Blob>();
        }

        /// <summary>
        /// Gets the list of blobs in the fake repository.
        /// </summary>
        /// <returns>List of blobs.</returns>
        public IList<Blob> Blobs { get; }

        /// <summary>
        /// Adds a new fake blob to the repository.
        /// </summary>
        /// <param name="containerName">The name of the container for the blob.</param>
        /// <param name="blobName">The name of the blob to create.</param>
        public void AddFakeBlob(string containerName, string blobName)
        {
            this.AddFakeBlob(
                new Blob(
                    AccountName,
                    containerName,
                    blobName,
                    new Dictionary<string, string>()));
        }

        /// <summary>
        /// Adds a new fake blob to the repository.
        /// </summary>
        /// <param name="blob">The blob to add to the repository.</param>
        public void AddFakeBlob(Blob blob)
        {
            this.Blobs.Add(blob);
        }

        /// <summary>
        /// Creates a placeholder for a blob that will be uploaded.
        /// </summary>
        /// <param name="containerName">Name of the container.</param>
        /// <param name="blobName">Name of the blob.</param>
        /// <returns>Fake Uri.</returns>
        public Task<Uri> GetBlobUploadUrlAsync(string containerName, string blobName)
        {
            return Task.FromResult(new Uri($"https://fakerepository/{containerName}/{blobName}?sasToken=Write"));
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

            return new Uri($"https://fakerepository/{blob.ContainerName}/{blob.BlobName}?sasToken=Read");
        }

        /// <summary>
        /// Gets a blob client for a single blob.
        /// </summary>
        /// <param name="containerName">Name of the container for the blob.</param>
        /// <param name="blobName">Name of the blob to get.</param>
        /// <returns>Blob that matches by name.</returns>
        public Task<Blob> GetBlobAsync(string containerName, string blobName)
        {
            var fakeBlob = this.Blobs.SingleOrDefault(i => i.ContainerName == containerName && i.BlobName == blobName);
            return Task.FromResult(fakeBlob);
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
            using var fileStream = System.IO.File.OpenRead("no-thats-not-gonna-do-it.wav");
            await fileStream.CopyToAsync(stream).ConfigureAwait(false);
            return;
        }

        /// <summary>
        /// Lists all the blobs in a folder.
        /// </summary>
        /// <param name="containerName">Name of the container holding the blobs to list.</param>
        /// <param name="prefix">Prefix of the blob name to filter by.</param>
        /// <returns>List of <see cref="Blob"/> whose name starts with the prefix.</returns>
        public Task<IList<Blob>> ListBlobsInFolderAsync(string containerName, string prefix)
        {
            var blobs = (IList<Blob>)this.Blobs
                .Where(b => b.ContainerName == containerName && b.BlobName.StartsWith($"{prefix}/", System.StringComparison.CurrentCulture))
                .ToList();
            return Task.FromResult(blobs);
        }

        /// <summary>
        /// Updates the properties of a blob.
        /// </summary>
        /// <param name="blob">The blob with the updated properties.</param>
        /// <returns>Task for performing the operation asynchronously.</returns>
        public Task UpdateBlobPropertiesAsync(Blob blob)
        {
            if (blob == null)
            {
                throw new ArgumentNullException(nameof(blob));
            }

            return Task.FromResult(default(object));
        }

        /// <summary>
        /// Deletes a blob.
        /// </summary>
        /// <param name="containerName">Container that holds the blob.</param>
        /// <param name="blobName">Name of the blob to delete.</param>
        /// <returns>Void.</returns>
        public Task DeleteBlobAsync(string containerName, string blobName)
        {
            var fakeBlob = this.Blobs.SingleOrDefault(i => i.ContainerName == containerName && i.BlobName == blobName);
            if (fakeBlob != null)
            {
                this.Blobs.Remove(fakeBlob);
            }

            return Task.CompletedTask;
        }
    }
}
