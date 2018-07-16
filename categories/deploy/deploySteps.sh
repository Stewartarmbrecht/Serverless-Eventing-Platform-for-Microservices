#!/bin/bash

#set -x
#set -e
#set -u

cd "${0%/*}"

# Categories Microservice Deploy

sh ./deploy-microservice.sh \
--resourceGroupName="$1-categories" \
--region="westus2" \
--deploymentFile="./microservice.json" \
--deploymentParameters="uniqueResourceNamePrefix,$1|bigHugeThesaurusApiKey,$2" \
--apiName=≈"$1-categories-api" \
--apiFilePath="./ContentReactor.Categories.Api.zip" \
--workerName="$1-categories-worker" \
--workerFilePath="./ContentReactor.Categories.WorkerApi.zip" \
--dbAccountName="$1-categories-db" \
--dbName="Categories" \
--dbCollectionNames="Categories" \
--dbPartitionKey="/userId" \
--storageAccountName="" \
--storageCollectionNames="" \
--eventResourceGroup="$1-events" \
--eventSubscriptionDeploymentFile="./eventGridSubscriptions-categories.json" \
--eventSubscriptionParameters="uniqueResourceNamePrefix,$1"
