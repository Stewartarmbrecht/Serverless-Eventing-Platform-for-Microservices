using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using ContentReactor.Images.Services.Models.Responses;
using ContentReactor.Images.Services.Models.Results;
using ContentReactor.Common;
using ContentReactor.Common.BlobRepository;
using ContentReactor.Common.EventSchemas.Images;
using SixLabors.ImageSharp;

namespace ContentReactor.Images.Services
{
    /// <summary>
    /// Interface for managing images.
    /// </summary>
    public interface IImagesService
    {
        /// <summary>
        /// Performas a health check of all depdendencies of the API service.
        /// </summary>
        /// <param name="app">Name of the application hosting the health check.</param>
        /// <param name="userId">Id of the user performing the health check.</param>
        /// <returns>HealthCheckResults</returns>
        Task<HealthCheckResults> HealthCheckApi(string userId, string app);
        /// <summary>
        /// Performs a health check of all dependencies of the worker service.
        /// </summary>
        /// <param name="app">Name of the application hosting the health check.</param>
        /// <param name="userId">Id of the user performing the health check.</param>
        /// <returns>HealthCheckResults</returns>
        Task<HealthCheckResults> HealthCheckWorker(string userId, string app);
        /// <summary>
        /// Creates a new image placeholder to upload an image to.
        /// </summary>
        /// <param name="userId">Id of the user uploading the image.</param>
        /// <returns>Dynamic object that contains the id of the new image object and the url to upload the image to.</returns>
        (string id, string url) BeginAddImageNote(string userId);
        /// <summary>
        /// Processes an image after it has been uploaded.
        /// </summary>
        /// <param name="imageId">Id of the image uploaded.</param>
        /// <param name="userId">Id of the user that uploaded the image.</param>
        /// <param name="categoryId">Id of the category the image was uploaded for.</param>
        /// <returns>Dynamic object that contains the reults of completing the image uploaded (CompleteAddImageNoteResults) 
        /// and the uri to the image preview.</returns>
        Task<(CompleteAddImageNoteResult result, string previewUri)> CompleteAddImageNoteAsync(string imageId, string userId, string categoryId);
        /// <summary>
        /// Gets a single the image note detail.
        /// </summary>
        /// <param name="id">Id of the image note detail to retrieve.</param>
        /// <param name="userId">Id of the user performing the operation.</param>
        /// <returns>ImageNoteDetail</returns>
        Task<ImageNoteDetails> GetImageNoteAsync(string id, string userId);
        /// <summary>
        /// Gets a list of image note summaries.
        /// </summary>
        /// <param name="userId">Id of the user performing the operation.</param>
        /// <returns>ImageNoteSummaries</returns>
        Task<ImageNoteSummaries> ListImageNotesAsync(string userId);
        /// <summary>
        /// Deletes a single Image Note.
        /// </summary>
        /// <param name="id">Id of the image note to delete.</param>
        /// <param name="userId">Id of the user performing the operation.</param>
        /// <returns>Void</returns>
        Task DeleteImageNoteAsync(string id, string userId);
        /// <summary>
        /// Updates the caption for an image.
        /// </summary>
        /// <param name="id">Id of the image note to update.</param>
        /// <param name="userId">Id of the user performing the operation.</param>
        /// <returns>UpdateImageNotCaptionResult</returns>
        Task<UpdateImageNoteCaptionResult> UpdateImageNoteCaptionAsync(string id, string userId);
    }

    /// <summary>
    /// Service for managing images.
    /// </summary>
    public class ImagesService : IImagesService
    {
        /// <summary>
        /// Blob repository for storing images.
        /// </summary>
        protected IBlobRepository BlobRepository;
        /// <summary>
        /// Service for validating images.
        /// </summary>
        protected IImageValidatorService ImageValidatorService;
        /// <summary>
        /// Service for creating image previews.
        /// </summary>
        protected IImagePreviewService ImagePreviewService;
        /// <summary>
        /// Service for getting image captions.
        /// </summary>
        protected IImageCaptionService ImageCaptionService;
        /// <summary>
        /// Service for publishing events.
        /// </summary>
        protected IEventGridPublisherService EventGridPublisherService;

        /// <summary>
        /// Name for the full image container.
        /// </summary>
        protected internal const string FullImagesBlobContainerName = "fullimages";
        /// <summary>
        /// Name of the preview image container.
        /// </summary>
        protected internal const string PreviewImagesBlobContainerName = "previewimages";
        /// <summary>
        /// Name of the meta data field for storing captions.
        /// </summary>
        protected internal const string CaptionMetadataName = "caption";
        /// <summary>
        /// Name of the meta data field for storing the category id.
        /// </summary>
        protected internal const string CategoryIdMetadataName = "categoryId";
        /// <summary>
        /// Name of the meta data field for storing the user id.
        /// </summary>
        protected internal const string UserIdMetadataName = "userId";
        /// <summary>
        /// Maximum image size to allow.
        /// </summary>
        protected internal const long MaximumImageSize = 4L * 1024L * 1024L;

        /// <summary>
        /// Creates a new image service.
        /// </summary>
        /// <param name="blobRepository">The responsitory to use for managing blobs.</param>
        /// <param name="imageValidatorService">The serivce to use for validating images.</param>
        /// <param name="imagePreviewService">The service to use for creating images previews.</param>
        /// <param name="imageCaptionService">The service to use for creating image captions.</param>
        /// <param name="eventGridPublisherService">The service to use for publishing events.</param>        
        public ImagesService(IBlobRepository blobRepository, IImageValidatorService imageValidatorService, IImagePreviewService imagePreviewService, IImageCaptionService imageCaptionService, IEventGridPublisherService eventGridPublisherService)
        {
            BlobRepository = blobRepository;
            ImageValidatorService = imageValidatorService;
            ImagePreviewService = imagePreviewService;
            ImageCaptionService = imageCaptionService;
            EventGridPublisherService = eventGridPublisherService;
        }

        /// <summary>
        /// Performas a health check of all depdendencies of the API service.
        /// </summary>
        /// <param name="app">Name of the application hosting the health check.</param>
        /// <param name="userId">Id of the user performing the health check.</param>
        /// <returns>HealthCheckResults</returns>
        public Task<HealthCheckResults> HealthCheckApi(string userId, string app)
        {
            var healthCheckResults = new HealthCheckResults() {
                    Status = HealthCheckStatus.OK,
                    Application = app
                };
            return Task.FromResult<HealthCheckResults>(healthCheckResults);
        }

        /// <summary>
        /// Performs a health check of all dependencies of the worker service.
        /// </summary>
        /// <param name="app">Name of the application hosting the health check.</param>
        /// <param name="userId">Id of the user performing the health check.</param>
        /// <returns>HealthCheckResults</returns>
        public Task<HealthCheckResults> HealthCheckWorker(string userId, string app)
        {
            var healthCheckResults = new HealthCheckResults() {
                    Status = HealthCheckStatus.OK,
                    Application = app
                };
            return Task.FromResult<HealthCheckResults>(healthCheckResults);
        }

        /// <summary>
        /// Creates a new image placeholder to upload an image to.
        /// </summary>
        /// <param name="userId">Id of the user uploading the image.</param>
        /// <returns>Dynamic object that contains the id of the new image object and the url to upload the image to.</returns>
        public (string id, string url) BeginAddImageNote(string userId)
        {
            // generate an ID for this image note
            var imageId = Guid.NewGuid().ToString();

            // create a blob placeholder (which will not have any contents yet)
            var blob = BlobRepository.CreatePlaceholderBlob(FullImagesBlobContainerName, userId, imageId);

            // get a SAS token to allow the client to write the blob
            // var writePolicy = new SharedAccessBlobPolicy
            // {
            //     SharedAccessStartTime = DateTime.UtcNow.AddMinutes(-5), // to allow for clock skew
            //     SharedAccessExpiryTime = DateTime.UtcNow.AddHours(24),
            //     Permissions = SharedAccessBlobPermissions.Create | SharedAccessBlobPermissions.Write
            // };

            StorageSharedKeyCredential credential = new StorageSharedKeyCredential();

            var url = BlobRepository.GetSasTokenForBlob(blob, credential);

            return (imageId, url);
        }

        /// <summary>
        /// Processes an image after it has been uploaded.
        /// </summary>
        /// <param name="imageId">Id of the image uploaded.</param>
        /// <param name="userId">Id of the user that uploaded the image.</param>
        /// <param name="categoryId">Id of the category the image was uploaded for.</param>
        /// <returns>Dynamic object that contains the reults of completing the image uploaded (CompleteAddImageNoteResults) 
        /// and the uri to the image preview.</returns>
        public async Task<(CompleteAddImageNoteResult result, string previewUri)> CompleteAddImageNoteAsync(string imageId, string userId, string categoryId)
        {
            var imageBlob = await BlobRepository.GetBlobAsync(FullImagesBlobContainerName, userId, imageId, true);
            if (imageBlob == null || !await imageBlob.ExistsAsync())
            {
                // the blob hasn't actually been uploaded yet, so we can't process it
                return (CompleteAddImageNoteResult.ImageNotUploaded, null);
            }

            var imageBlobProp = await imageBlob.GetPropertiesAsync();

            using (var rawImage = new MemoryStream((int)imageBlobProp.Value.ContentLength))
            {
                // get the image that was uploaded by the client
                await BlobRepository.DownloadBlobAsync(imageBlob, rawImage);
                if (rawImage.CanSeek)
                {
                    rawImage.Position = 0;
                }

                // if the blob already contains metadata then that means it has already been added
                if (imageBlobProp.Value.Metadata.ContainsKey(CategoryIdMetadataName))
                {
                    return (CompleteAddImageNoteResult.ImageAlreadyCreated, null);
                }

                // validate the size of the image
                if (rawImage.Length > MaximumImageSize) // TODO confirm this works
                {
                    return (CompleteAddImageNoteResult.ImageTooLarge, null);
                }

                // validate the image is in an acceptable format
                var validationResult = ImageValidatorService.ValidateImage(rawImage);
                if (!validationResult.isValid)
                {
                    return (CompleteAddImageNoteResult.InvalidImage, null);
                }
                if (rawImage.CanSeek)
                {
                    rawImage.Position = 0;
                }

                // set the blob metadata
                Dictionary<string, string> metadata = new Dictionary<string, string>();
                metadata.Add(CategoryIdMetadataName, categoryId);
                metadata.Add(UserIdMetadataName, userId);
                metadata.Add("ContentType", validationResult.mimeType); // the actual detected content type, regardless of what the client may have told us when it uploaded the blob

                // imageBlobProp.Value.ContentType = validationResult.mimeType; 
                //await BlobRepository.UpdateBlobMetadataAsync(imageBlob);

                await imageBlob.SetMetadataAsync(metadata);

                // create and upload a preview image for this blob
                BlobClient previewImageBlob;
                using (var previewImageStream = ImagePreviewService.CreatePreviewImage(rawImage))
                {
                    previewImageBlob = await BlobRepository.UploadBlobAsync(PreviewImagesBlobContainerName, userId, imageId, previewImageStream, ImageFormats.Jpeg.DefaultMimeType);
                }

                // get a reference to the preview image with a SAS token
                var getPolicy = new SharedAccessBlobPolicy
                {
                    SharedAccessStartTime = DateTime.UtcNow.AddMinutes(-5), // to allow for clock skew
                    SharedAccessExpiryTime = DateTime.UtcNow.AddHours(24),
                    Permissions = SharedAccessBlobPermissions.Read
                };
                var previewUrl = BlobRepository.GetSasTokenForBlob(previewImageBlob, getPolicy);
            
                // publish an event into the Event Grid topic
                var eventSubject = $"{userId}/{imageId}";
                await EventGridPublisherService.PostEventGridEventAsync(EventTypes.Images.ImageCreated, eventSubject, new ImageCreatedEventData { PreviewUri = previewUrl, Category = categoryId});

                return (CompleteAddImageNoteResult.Success, previewUrl);
            }
        }

        /// <summary>
        /// Gets a single the image note detail.
        /// </summary>
        /// <param name="id">Id of the image note detail to retrieve.</param>
        /// <param name="userId">Id of the user performing the operation.</param>
        /// <returns>ImageNoteDetail</returns>
        public async Task<ImageNoteDetails> GetImageNoteAsync(string id, string userId)
        {
            var getPolicy = new SharedAccessBlobPolicy
            {
                SharedAccessStartTime = DateTime.UtcNow.AddMinutes(-5), // to allow for clock skew
                SharedAccessExpiryTime = DateTime.UtcNow.AddHours(24),
                Permissions = SharedAccessBlobPermissions.Read
            };

            // get the full-size blob, if it exists
            var imageBlob = await BlobRepository.GetBlobAsync(FullImagesBlobContainerName, userId, id, true);
            if (imageBlob == null)
            {
                return null;
            }
            var imageUrl = BlobRepository.GetSasTokenForBlob(imageBlob, getPolicy);
            imageBlob.Metadata.TryGetValue(CaptionMetadataName, out var caption);

            // get the preview blob, if it exists
            var previewBlob = await BlobRepository.GetBlobAsync(PreviewImagesBlobContainerName, userId, id);
            string previewUrl = null;
            if (previewBlob != null)
            {
                previewUrl = BlobRepository.GetSasTokenForBlob(previewBlob, getPolicy);
            }

            return new ImageNoteDetails
            {
                Id = id,
                ImageUrl = imageUrl,
                PreviewUrl = previewUrl,
                Caption = caption
            };
        }

        /// <summary>
        /// Gets a list of image note summaries.
        /// </summary>
        /// <param name="userId">Id of the user performing the operation.</param>
        /// <returns>ImageNoteSummaries</returns>
        public async Task<ImageNoteSummaries> ListImageNotesAsync(string userId)
        {
            var blobs = await BlobRepository.ListBlobsInFolderAsync(FullImagesBlobContainerName, userId);
            var getPolicy = new SharedAccessBlobPolicy
            {
                SharedAccessStartTime = DateTime.UtcNow.AddMinutes(-5), // to allow for clock skew
                SharedAccessExpiryTime = DateTime.UtcNow.AddHours(24),
                Permissions = SharedAccessBlobPermissions.Read
            };

            var blobListQueries = blobs
                .Select(async b => new ImageNoteSummary
                {
                    Id = b.Name.Split('/')[1],
                    Preview = BlobRepository.GetSasTokenForBlob(await BlobRepository.GetBlobAsync(PreviewImagesBlobContainerName, userId, b.Name.Split('/')[1]), getPolicy)
                })
                .ToList();
            await Task.WhenAll(blobListQueries);

            var blobList = blobListQueries.Select(q => q.Result).ToList();

            var summaries = new ImageNoteSummaries();
            summaries.AddRange(blobList);
            return summaries;
        }

        /// <summary>
        /// Deletes a single Image Note.
        /// </summary>
        /// <param name="id">Id of the image note to delete.</param>
        /// <param name="userId">Id of the user performing the operation.</param>
        /// <returns>Void</returns>
        public async Task DeleteImageNoteAsync(string id, string userId)
        {
            // delete both image blobs
            var deleteFullImageTask = BlobRepository.DeleteBlobAsync(FullImagesBlobContainerName, userId, id);
            var deletePreviewImageTask = BlobRepository.DeleteBlobAsync(PreviewImagesBlobContainerName, userId, id);
            await Task.WhenAll(deleteFullImageTask, deletePreviewImageTask);

            // fire an event into the Event Grid topic
            var eventSubject = $"{userId}/{id}";
            await EventGridPublisherService.PostEventGridEventAsync(EventTypes.Images.ImageDeleted, eventSubject, new ImageDeletedEventData());
        }

        /// <summary>
        /// Updates the caption for an image.
        /// </summary>
        /// <param name="id">Id of the image note to update.</param>
        /// <param name="userId">Id of the user performing the operation.</param>
        /// <returns>UpdateImageNotCaptionResult</returns>
        public async Task<UpdateImageNoteCaptionResult> UpdateImageNoteCaptionAsync(string id, string userId)
        {
            // get the full-size blob, if it exists
            var imageBlob = await BlobRepository.GetBlobAsync(FullImagesBlobContainerName, userId, id, true);
            if (imageBlob == null)
            {
                return UpdateImageNoteCaptionResult.NotFound;
            }

            // get the image bytes
            var bytes = await BlobRepository.GetBlobBytesAsync(imageBlob);
            
            // get the caption
            var caption = await ImageCaptionService.GetImageCaptionAsync(bytes);

            if(!String.IsNullOrEmpty(caption) && caption.Contains("apple")) { caption = $"{caption} YumYum!"; }

            // update the blob with the new caption
            imageBlob.Metadata[CaptionMetadataName] = caption;
            await BlobRepository.UpdateBlobMetadataAsync(imageBlob);

            // fire an event into the Event Grid topic
            var eventSubject = $"{userId}/{id}";
            await EventGridPublisherService.PostEventGridEventAsync(EventTypes.Images.ImageCaptionUpdated, eventSubject, new ImageCaptionUpdatedEventData { Caption = caption });

            return UpdateImageNoteCaptionResult.Success;
        }
    }
}
