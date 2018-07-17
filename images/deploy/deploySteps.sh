#!/bin/bash
set -e
set -u

cd "${0%/*}"

chmod u+x ./deploy-microservice.sh

# Images Microservice Deploy

./scripts/deploy-microservice.sh \
--resourceGroupName="$1-images" \
--region="westus2" \
--deploymentFile="./microservice.json" \
--deploymentParameters="uniqueResourceNamePrefix,$1" \
--apiName="$1-images-api" \
--apiFilePath="./ContentReactor.Images.Api.zip" \
--workerName="$1-images-worker" \
--workerFilePath="./ContentReactor.Images.WorkerApi.zip" \
--dbAccountName="" \
--dbName="" \
--dbCollectionNames="" \
--dbPartitionKey="" \
--storageAccountName="$1imagesblob" \
--storageCollectionNames="fullimages,previewimages" \
--eventResourceGroup="$1-events" \
--eventSubscriptionDeploymentFile="./eventGridSubscriptions-images.json" \
--eventSubscriptionParameters="uniqueResourceNamePrefix,$1"
