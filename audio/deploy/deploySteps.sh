#!/bin/bash
set -e
set -u

cd "${0%/*}"


D() { echo -e '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }


# Audio Microservice Deploy

D "Creating audio resource group for $1."
time az group create -n $1"-audio" -l westus2
D "Created audio resource group for $1."

time sleep 2

D "Executing audio deployment for $1."
time az group deployment create -g $1"-audio" --template-file ./microservice.json --parameters uniqueResourceNamePrefix=$1 --mode Complete
D "Executed audio deployment for $1."

time sleep 2

AUDIO_API_NAME=$1"-audio-api"
AUDIO_WORKER_API_NAME=$1"-audio-worker"
AUDIO_BLOB_STORAGE_ACCOUNT_NAME=$1"audioblob"

D "Creating audio blob storage for $1."
time az storage container create --account-name $AUDIO_BLOB_STORAGE_ACCOUNT_NAME --name audio
D "Created audio blob storage for $1."

time sleep 2

D "Creating audio CORS policy for blob storage for $1."
time az storage cors clear --account-name $AUDIO_BLOB_STORAGE_ACCOUNT_NAME --services b
time az storage cors add --account-name $AUDIO_BLOB_STORAGE_ACCOUNT_NAME --services b --methods POST GET PUT --origins "*" --allowed-headers "*" --exposed-headers "*"
D "Created audio CORS policy for blob storage for $1."

time sleep 2

D "Deploying audio api function for $1."
time az webapp deployment source config-zip --resource-group $1"-audio" --name $AUDIO_API_NAME --src ../src/ContentReactor.Audio/ContentReactor.Audio.Api/bin/Release/netstandard2.0/ContentReactor.Audio.Api.zip
D "Deployed audio api function for $1."
time sleep 3

time sleep 2

D "Deploying audio worker function for $1."
time az webapp deployment source config-zip --resource-group $1"-audio" --name $AUDIO_WORKER_API_NAME --src ../src/ContentReactor.Audio/ContentReactor.Audio.WorkerApi/bin/Release/netstandard2.0/ContentReactor.Audio.WorkerApi.zip
D "Deployed audio worker function for $1."

time sleep 2

D "Deploying audio event grid subscription for $1."
time az group deployment create -g $1"-events" --template-file ./eventGridSubscriptions-audio.json --parameters uniqueResourceNamePrefix=$1
D "Deployed audio event grid subscription for $1."

time sleep 5
			
D "Completed audio deployment for $1."
