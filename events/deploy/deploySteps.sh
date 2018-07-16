#!/bin/bash
set -e
set -u

cd "${0%/*}"

# Creating Event Grid Topic
chmod u+x ./deploy-microservice.sh

./deploy-microservice.sh \
--resourceGroupName="$1-events" \
--region="westus2" \
--deploymentFile="./template.json" \
--deploymentParameters="uniqueResourceNamePrefix,$1" \
--apiName="" \
--apiFilePath="" \
--workerName="" \
--workerFilePath="" \
--dbAccountName="" \
--dbName="" \
--dbCollectionNames="" \
--dbPartitionKey="" \
--storageAccountName="" \
--storageCollectionNames="" \
--eventResourceGroup="" \
--eventSubscriptionDeploymentFile="" \
--eventSubscriptionParameters=""
