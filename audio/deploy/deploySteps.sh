#!/bin/bash
set -e
set -u

cd "${0%/*}"

# Audio Microservice Deploy

chmod u+x ./deploy-microservice.sh

./scripts/deploy-microservice.sh \
--resourceGroupName="$1-audio" \
--region="westus2" \
--deploymentFile="./microservice.json" \
--deploymentParameters="uniqueResourceNamePrefix,$1" \
--apiName="$1-audio-api" \
--apiFilePath="./ContentReactor.Audio.Api.zip" \
--workerName="$1-audio-worker" \
--workerFilePath="./ContentReactor.Audio.WorkerApi.zip" \
--dbAccountName="" \
--dbName="" \
--dbCollectionNames="" \
--dbPartitionKey="" \
--storageAccountName="$1audioblob" \
--storageCollectionNames="audio" \
--eventResourceGroup="$1-events" \
--eventSubscriptionDeploymentFile="./eventGridSubscriptions-audio.json" \
--eventSubscriptionParameters="uniqueResourceNamePrefix,$1"
