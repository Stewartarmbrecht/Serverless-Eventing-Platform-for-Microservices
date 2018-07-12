#!/bin/bash
set -e
set -u

cd "${0%/*}"


D() { echo -e '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }


# Deploy Proxy
D "Creating the api proxy resource group for $1."
time az group create -n $1"-proxy" -l westus2
D "Created the api proxy resource group for $1."

time sleep 2

D "Executing api proxy deployment for $1."
time az group deployment create -g $1"-proxy" --template-file ./template.json --parameters uniqueResourceNamePrefix=$1 --mode Complete
D "Executed api proxy deployment for $1."

time sleep 2

D "Deploying proxy function app for $1."
PROXY_API_NAME=$1"-proxy-api"
time az webapp deployment source config-zip --resource-group $1"-proxy" --name $PROXY_API_NAME --src ../proxies/proxies.zip
D "Deployed proxy function app for $1."

time sleep 2

D "Completed proxy deployment for $1."
