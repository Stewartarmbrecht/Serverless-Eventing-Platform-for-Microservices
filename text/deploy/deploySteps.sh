#!/bin/bash
set -e
set -u

cd "${0%/*}"


D() { echo -e '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }


D "Creating text resource group for $1."
time az group create -n $1"-text" -l westus2
D "Created text resource group for $1."

time sleep 2

D "Executing text deployment for $1."
time az group deployment create -g $1"-text" --template-file ./microservice.json --parameters uniqueResourceNamePrefix=$1 --mode Complete
D "Executed text deployment for $1."

time sleep 2

D "Creating text cosmos db for $1."
TEXT_COSMOSDB_STORAGE_ACCOUNT_NAME=$1"-text-db"
time az cosmosdb database create --name $TEXT_COSMOSDB_STORAGE_ACCOUNT_NAME --db-name Text --resource-group $1"-text"
D "Created text cosmos db for $1."

time sleep 2

D "Creating text cosmos collection for $1."
time az cosmosdb collection create --name $TEXT_COSMOSDB_STORAGE_ACCOUNT_NAME --db-name Text --collection-name Text --resource-group $1"-text" --partition-key-path "/userId" --throughput 400
D "Created text cosmos collection for $1."

time sleep 2

D "Deploying text api functions for $1."
TEXT_API_NAME=$1"-text-api"
time az webapp deployment source config-zip --resource-group $1"-text" --name $TEXT_API_NAME --src ../src/ContentReactor.Text/ContentReactor.Text.Api/bin/Release/netstandard2.0/ContentReactor.Text.Api.zip
D "Deployed text api functions for $1."

time sleep 2

D "Completed text deployment for $1."
