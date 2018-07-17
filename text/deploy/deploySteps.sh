#!/bin/bash
set -e
set -u

cd "${0%/*}"

# Text Microservice Deploy

chmod u+x ./deploy-microservice.sh

./deploy-microservice.sh \
--resourceGroupName=$1"-text" \
--region="westus2" \
--deploymentFile="./microservice.json" \
--deploymentParameters="uniqueResourceNamePrefix,$1" \
--apiName=$1"-text-api" \
--apiFilePath="./ContentReactor.Text.Api.zip" \
--workerName="" \
--workerFilePath="" \
--dbAccountName=$1"-text-db" \
--dbName="Text" \
--dbCollectionNames="Text" \
--dbPartitionKey="/userId" \
--storageAccountName="" \
--storageCollectionNames="" \
--eventResourceGroup="" \
--eventSubscriptionDeploymentFile="" \
--eventSubscriptionParameters=""
