#!/bin/bash

#set -x

usage()
{
    echo "This script creats a generic function based microservice.  It responds to the following parameters."
    echo ""
    echo "./deploy-microservice.sh"
    echo "\t-h --help"
    echo "\t--resourceGroupName: Resource group name for the microservice."
    echo "\t--region: Region for the microservice."
    echo "\t--deploymentFile: The deployment file for the resource group."
    echo "\t--deploymentParameters: Pipe and Comma separated list of parameters: ParameterName,Value|Parameter2Name,Value"
    echo "\t--apiName: The name of the api function app."
    echo "\t--apiFilePath: The path to the zip package to deploy for the function app."
    echo "\t--workerName: The name of the worker function app."
    echo "\t--workerFilePath: The path to the zip package to deploy for the function app."
    echo "\t--dbAccountName: Set to string value if you want to create a Cosmos DB database account, db, and collection with the name you provide."
    echo "\t--dbName: Set to string value if you want to create a Cosmos DB database account, db, and collection with the name you provide."
    echo "\t--dbCollectionName: Set to comma separated string if you want to create a Cosmos DB database account, db, and collection(s) with the name you provide."
    echo "\t--dbPartitionKey: Set to comma separated string if you want to create a Cosmos DB database account, db, and collection(s) with the name you provide."
    echo "\t--storageAccountName: Set to string value if you want to create a blob storage account with one or more containers."
    echo "\t--storageContainerNames: Set to comma separated string if you want to create a blob storage account with one or more containers."
    echo "\t--eventResourceGroup: Set to string value if you want to create a worker function app that subscribes to an event grid topic."
    echo "\t--eventSubscriptionDeploymentFile: Set to path to the ARM deployment file to create the event grid subscription."
    echo "\t--eventSubscriptionParameters: Pipe and Comma separated list of parameters: ParameterName,Value|Parameter2Name,Value"
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --resourceGroupName)
            RESOURCE_GROUP_NAME=$VALUE
            ;;
        --region)
            REGION=$VALUE
            ;;
        --deploymentFile)
            DEPLOYMENT_FILE=$VALUE
            ;;
        --deploymentParameters)
            DEPLOYMENT_PARAMETERS=$VALUE
            ;;
        --apiName)
            API_NAME=$VALUE
            ;;
        --apiFilePath)
            API_FILE_PATH=$VALUE
            ;;
        --workerName)
            WORKER_NAME=$VALUE
            ;;
        --workerFilePath)
            WORKER_FILE_PATH=$VALUE
            ;;
        --dbAccountName)
            DB_ACCOUNT_NAME=$VALUE
            ;;
        --dbName)
            DB_NAME=$VALUE
            ;;
        --dbCollectionNames)
            DB_COLLECTION_NAMES=$VALUE
            ;;
        --dbPartitionKey)
            DB_PARTITION_KEY=$VALUE
            ;;
        --storageAccountName)
            STORAGE_ACCOUNT_NAME=$VALUE
            ;;
        --storageCollectionNames)
            STORAGE_COLLECTION_NAMES=$VALUE
            ;;
        --eventResourceGroup)
            EVENTS_RESOURCE_GROUP_NAME=$VALUE
            ;;
        --eventSubscriptionDeploymentFile)
            EVENTS_SUBSCRIPTION_DEPLOYMENT_FILE=$VALUE
            ;;
        --eventSubscriptionParameters)
            EVENTS_SUBSCRIPTION_PARAMETERS=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

D() { echo '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }
E() { echo '\033[1;31m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }

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
