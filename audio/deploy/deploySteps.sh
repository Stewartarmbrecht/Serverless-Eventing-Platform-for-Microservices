#!/bin/bash
set -e
set -u

cd "${0%/*}"

# Audio Microservice Deploy

../../scripts/deploy-microservice.sh \
--resourceGroupName=$1"-audio" \
--region="westus2" \
--deploymentFile="./microservice.json" \
--deploymentParameters="uniqueResourceNamePrefix,$1" \
--apiName=$1"-audio-api" \
--apiFilePath="../src/ContentReactor.Audio/ContentReactor.Audio.Api/bin/Release/netstandard2.0/ContentReactor.Audio.Api.zip" \
--workerName=$1"-audio-worker" \
--workerFilePath="../src/ContentReactor.Audio/ContentReactor.Audio.WorkerApi/bin/Release/netstandard2.0/ContentReactor.Audio.WorkerApi.zip" \
--dbAccountName="" \
--dbName="" \
--dbCollectionNames="" \
--dbPartitionKey="" \
--storageAccountName=$1"audioblob" \
--storageCollectionNames="audio" \
--eventResourceGroup=$1"-events" \
--eventSubscriptionDeploymentFile="./eventGridSubscriptions-audio.json" \
--eventSubscriptionParameters="uniqueResourceNamePrefix,$1"
