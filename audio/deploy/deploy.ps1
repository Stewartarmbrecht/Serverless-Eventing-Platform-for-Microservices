#!/bin/bash


function D([string]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $($value)"  -ForegroundColor DarkCyan }
function E([string]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $($value)"  -ForegroundColor DarkRed }

# Categories Microservice Deploy

D "Creating the $RESOURCE_GROUP_NAME resource group in the $REGION region."
time az group create -n $RESOURCE_GROUP_NAME -l $REGION
D "Created the $RESOURCE_GROUP_NAME resource group in the $REGION region."

i=0
found=$(az group exists -n $RESOURCE_GROUP_NAME)
if [ "$found" = "true" ]; then
	D "Found Resource Group $RESOURCE_GROUP_NAME."
fi

while [ $i -lt 5 -a "$found" != "true" ]
do
	sleep 2
	E "Waiting for the $RESOURCE_GROUP_NAME to be created."
	found=$(az group exists -n $RESOURCE_GROUP_NAME)
	i=$(($i+1))
done
if [ "$found" != "true" ]; then
	E "$RESOURCE_GROUP_NAME resource group not found."
	exit 1;
fi

sleep 5 # Waiting 5 seconds to allow the resource group to finish deployment.

D "Parameters: $DEPLOYMENT_PARAMETERS"

SEP=","
SPACE=" "
EQUAL="="
DEPLOYMENT_PARAMETERS="${DEPLOYMENT_PARAMETERS//|/$SPACE}"
DEPLOYMENT_PARAMETERS="${DEPLOYMENT_PARAMETERS//,/$EQUAL}"

D "Executing the $RESOURCE_GROUP_NAME deployment."
D "\tUsing file: $DEPLOYMENT_FILE"
D "\tUsing parameters: $DEPLOYMENT_PARAMETERS"
time az group deployment create \
	-g $RESOURCE_GROUP_NAME \
	--template-file $DEPLOYMENT_FILE \
	--parameters $DEPLOYMENT_PARAMETERS \
	--mode Complete
D "Executed the $RESOURCE_GROUP_NAME deployment."

if [ "$DB_ACCOUNT_NAME" ]; then
	D "Creating $RESOURCE_GROUP_NAME cosmos db."
	D "\tUsing DB account name: $DB_ACCOUNT_NAME"
	D "\tUsing DB name: $DB_NAME"
	if [ "$(time az cosmosdb database create \
		--name $DB_ACCOUNT_NAME \
		--db-name $DB_NAME \
		--resource-group $RESOURCE_GROUP_NAME)" ]; then
			D "Created $RESOURCE_GROUP_NAME cosmos db."
	else
		D "Failed to created $RESOURCE_GROUP_NAME cosmos db."
	fi

	D "Creating $RESOURCE_GROUP_NAME cosmos db collections ($DB_COLLECTION_NAMES) for $DB_ACCOUNT_NAME in $DB_NAME."
	IN=$DB_COLLECTION_NAMES
	IFS=',' read -ra NAMES <<< "$IN"    #Convert string to array
	for i in "${NAMES[@]}"; do
		D "Creating $RESOURCE_GROUP_NAME cosmos db collection ($i) for $DB_ACCOUNT_NAME in $DB_NAME."
		if [ "$(time az cosmosdb collection create \
				--name $DB_ACCOUNT_NAME \
				--db-name $DB_NAME \
				--collection-name $i \
				--resource-group $RESOURCE_GROUP_NAME \
				--partition-key-path $DB_PARTITION_KEY \
				--throughput 400)" ]; then  
			D "Created $RESOURCE_GROUP_NAME cosmos db collection ($i) for $DB_ACCOUNT_NAME in $DB_NAME."
		else
			E "Failed to create $RESOURCE_GROUP_NAME cosmos db collection ($i) for $DB_ACCOUNT_NAME in $DB_NAME."
		fi
	done
	D "Created $RESOURCE_GROUP_NAME cosmos db collections ($DB_COLLECTION_NAMES) for $DB_ACCOUNT_NAME in $DB_NAME."
fi

if [ "$STORAGE_ACCOUNT_NAME" != "" ]; then
	D "Creating $RESOURCE_GROUP_NAME storage account containers ($STORAGE_COLLECTION_NAMES) for $STORAGE_ACCOUNT_NAME."
	IN=$STORAGE_COLLECTION_NAMES
	IFS=',' read -ra NAMES <<< "$IN"    #Convert string to array
	for i in "${NAMES[@]}"; do
		D "Creating $RESOURCE_GROUP_NAME storage account container ($i) for $STORAGE_ACCOUNT_NAME."
		if [ "$(time az storage container create --account-name $STORAGE_ACCOUNT_NAME --name $i)" ]; then
			D "Created $RESOURCE_GROUP_NAME storage account container ($i) for $STORAGE_ACCOUNT_NAME."
		else
			D "Failed to create $RESOURCE_GROUP_NAME storage account container ($i) for $STORAGE_ACCOUNT_NAME."
		fi
	done

	D "Creating $RESOURCE_GROUP_NAME CORS policy for storage account $STORAGE_ACCOUNT_NAME."
	time az storage cors clear --account-name $STORAGE_ACCOUNT_NAME --services b
	time az storage cors add --account-name $STORAGE_ACCOUNT_NAME \
		--services b --methods POST GET PUT \
		--origins "*" --allowed-headers "*" --exposed-headers "*"
	D "Created $RESOURCE_GROUP_NAME CORS policy for storage account $STORAGE_ACCOUNT_NAME."
fi

if [ "$API_NAME" != "" ]; then
	D "Deploying $RESOURCE_GROUP_NAME api function:"
	D "\tUsing name: $API_NAME"
	D "\tUsing file path: $API_FILE_PATH"
	time az webapp deployment source config-zip \
		--resource-group $RESOURCE_GROUP_NAME \
		--name $API_NAME \
		--src $API_FILE_PATH
	D "Deployed $RESOURCE_GROUP_NAME api function:"
	D "\tUsing name: $API_NAME"
	D "\tUsing file path: $API_FILE_PATH"
fi

if [ "$WORKER_NAME" != "" ]; then
	D "Deploying $RESOURCE_GROUP_NAME worker function:"
	D "\tUsing name: $WORKER_NAME"
	D "\tUsing file path: $WORKER_FILE_PATH"
	time az webapp deployment source config-zip \
		--resource-group $RESOURCE_GROUP_NAME \
		--name $WORKER_NAME \
		--src $WORKER_FILE_PATH
	D "Deployed $RESOURCE_GROUP_NAME worker function:"
	D "\tUsing name: $WORKER_NAME"
	D "\tUsing file path: $WORKER_FILE_PATH"
fi

if [ "$EVENTS_RESOURCE_GROUP_NAME" != "" ]; then
	EVENTS_SUBSCRIPTION_PARAMETERS="${EVENTS_SUBSCRIPTION_PARAMETERS//|/$SPACE}"
	EVENTS_SUBSCRIPTION_PARAMETERS="${EVENTS_SUBSCRIPTION_PARAMETERS//,/$EQUAL}"
	D "Deploying $RESOURCE_GROUP_NAME event grid subscription to event grid in $EVENTS_RESOURCE_GROUP_NAME."
	D "\tUsing file path: $EVENTS_SUBSCRIPTION_DEPLOYMENT_FILE"
	D "\tUsing parameters: $EVENTS_SUBSCRIPTION_PARAMETERS"
	time az group deployment create -g $EVENTS_RESOURCE_GROUP_NAME \
		--template-file $EVENTS_SUBSCRIPTION_DEPLOYMENT_FILE \
		--parameters $EVENTS_SUBSCRIPTION_PARAMETERS
	D "Deployed $RESOURCE_GROUP_NAME event grid subscription to event grid in $EVENTS_RESOURCE_GROUP_NAME."
	D "\tUsing file path: $EVENTS_SUBSCRIPTION_DEPLOYMENT_FILE"
	D "\tUsing parameters: $EVENTS_SUBSCRIPTION_PARAMETERS"
fi

D "Completed $RESOURCE_GROUP_NAME deployment.."
