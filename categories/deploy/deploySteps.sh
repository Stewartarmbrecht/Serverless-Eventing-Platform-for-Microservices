#!/bin/bash
set -e
set -u

cd "${0%/*}"


D() { echo -e '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }


# Categories Microservice Deploy

D "Creating the categories resource group for $1."
time az group create -n $1"-categories" -l westus2
D "Created the categories resource group for $1."

time sleep 2

D "Executing the categories deployment for $1."
time az group deployment create -g $1"-categories" --template-file ./microservice.json --parameters uniqueResourceNamePrefix=$1 bigHugeThesaurusApiKey=$2 --mode Complete
D "Executed the categories deployment for $1."

time sleep 2

D "Creating categories cosmos db for $1."
COSMOS_DB_ACCOUNT_NAME=$1"-categories-db"
time az cosmosdb database create --name $COSMOS_DB_ACCOUNT_NAME --db-name Categories --resource-group $1"-categories"
D "Created categories cosmos db for $1."

time sleep 2

D "Creating categories cosmos db collection for $1."
time az cosmosdb collection create --name $COSMOS_DB_ACCOUNT_NAME --db-name Categories --collection-name Categories --resource-group $1"-categories" --partition-key-path "/userId" --throughput 400
D "Created categories cosmos db collection for $1."

time sleep 2

CATEGORIES_API_NAME=$1"-categories-api"
CATEGORIES_WORKER_API_NAME=$1"-categories-worker"

D "Deploying categories api functions for $1."
time az webapp deployment source config-zip --resource-group $1"-categories" --name $CATEGORIES_API_NAME --src ../src/ContentReactor.Categories/ContentReactor.Categories.Api/bin/Release/netstandard2.0/ContentReactor.Categories.Api.zip
D "Deployed categories api functions for $1."

time sleep 2

D "Deploying categories worker functions for $1."
time az webapp deployment source config-zip --resource-group $1"-categories" --name $CATEGORIES_WORKER_API_NAME --src ../src/ContentReactor.Categories/ContentReactor.Categories.WorkerApi/bin/Release/netstandard2.0/ContentReactor.Categories.WorkerApi.zip
D "Deployed categories worker functions for $1."

time sleep 2

D "Deploying categories event grid subscription for $1."
time az group deployment create -g $1"-events" --template-file ./eventGridSubscriptions-categories.json --parameters uniqueResourceNamePrefix=$1
D "Deployed categories event grid subscription for $1."

time sleep 5

D "Completed categories deployment. for $1."
