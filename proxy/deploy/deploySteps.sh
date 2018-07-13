#!/bin/bash
set -e
set -u

cd "${0%/*}"

# Deploy Proxy

../../scripts/deploy-microservice.sh \
--resourceGroupName=$1"-proxy" \
--region="westus2" \
--deploymentFile="./template.json" \
--deploymentParameters="uniqueResourceNamePrefix,$1" \
--apiName=$1"-proxy-api" \
--apiFilePath="../proxies/proxies.zip" \
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
