#!/bin/bash
set -e
set -u

cd "${0%/*}"


D() { echo -e '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }


# Images Microservice Deploy

D "Creating images resource group for $1."
time az group create -n $1"-images" -l westus2
D "Created images resource group for $1."

time sleep 2

D "Executing images deployment for $1."
time az group deployment create -g $1"-images" --template-file ./microservice.json --parameters uniqueResourceNamePrefix=$1 --mode Complete
D "Executed images deployment for $1."

time sleep 2

IMAGES_API_NAME=$1"-images-api"
IMAGES_WORKER_API_NAME=$1"-images-worker"
IMAGES_BLOB_STORAGE_ACCOUNT_NAME=$1"imagesblob"

D "Creating images blob storage for $1."
time az storage container create --account-name $IMAGES_BLOB_STORAGE_ACCOUNT_NAME --name fullimages
time az storage container create --account-name $IMAGES_BLOB_STORAGE_ACCOUNT_NAME --name previewimages
D "Created images blob storage for $1."

D "Creating images blob CORS policy for $1."
time az storage cors clear --account-name $IMAGES_BLOB_STORAGE_ACCOUNT_NAME --services b
time az storage cors add --account-name $IMAGES_BLOB_STORAGE_ACCOUNT_NAME --services b --methods POST GET PUT --origins "*" --allowed-headers "*" --exposed-headers "*"
D "Created images blob CORS policy for $1."

D "Deploying images api functions for $1."
time az webapp deployment source config-zip --resource-group $1"-images" --name $IMAGES_API_NAME --src ../src/ContentReactor.Images/ContentReactor.Images.Api/bin/Release/netstandard2.0/ContentReactor.Images.Api.zip
D "Deployed images api functions for $1."

time sleep 2

D "Deploying images worker functions for $1."
time az webapp deployment source config-zip --resource-group $1"-images" --name $IMAGES_WORKER_API_NAME --src ../src/ContentReactor.Images/ContentReactor.Images.WorkerApi/bin/Release/netstandard2.0/ContentReactor.Images.WorkerApi.zip
D "Deployed images worker functions for $1."

time sleep 2

D "Deploying images event grid subscription for $1."
time az group deployment create -g $1"-events" --template-file ./eventGridSubscriptions-images.json --parameters uniqueResourceNamePrefix=$1
D "Deployed images event grid subscription for $1."

time sleep 5

D "Completed  deployment for $1."
