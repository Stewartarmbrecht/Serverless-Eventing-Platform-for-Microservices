param([String]$namePrefix,[String]$region)
if (!$namePrefix) {
    $namePrefix = $Env:namePrefix
}
if (!$region) {
    $region = $Env:region
}
$loggingPrefix = "Text Deployment ($namePrefix)"
$resourceGroupName = "$namePrefix-text"
$deploymentFile = "./microservice.json"
$dbAccountName="$namePrefix-text-db"
$dbName="Text"
$dbCollectionName="Text"
$dbPartitionKey="/userId"
$dbThroughput = 400

Set-Location "$PSSCriptRoot"

. ./../../scripts/functions.ps1

if (!$namePrefix) {
    D "Either pass in the '-namePrefix' parameter when calling this script or 
    set and environment variable with the name: 'namePrefix'." $loggingPrefix
}
if (!$region) {
    D "Either pass in the '-region' parameter when calling this script or 
    set and environment variable with the name: 'region'." $loggingPrefix
}

D "Deploying the microservice." $loggingPrefix

$command = "az group create -n $resourceGroupName -l $region"
$result = ExecuteCommand $command $loggingPrefix "Creating the resource group."

$command = "az group deployment create -g $resourceGroupName --template-file $deploymentFile --mode Complete --parameters uniqueResourceNamePrefix=$namePrefix"
$result = ExecuteCommand $command $loggingPrefix "Deploying the infrastructure."

$command = "az cosmosdb database exists --name $dbAccountName --db-name $dbName --resource-group $resourceGroupName"
$result = ExecuteCommand $command $loggingPrefix "Checking if CosmosDB exists."
if(!$result) {
    $command = "az cosmosdb database create --name $dbAccountName --db-name $dbName --resource-group $resourceGroupName"
    ExecuteCommand $command $loggingPrefix "Creating the Cosmos DB database."
}

$command = "az cosmosdb collection exists --name $dbAccountName --db-name $dbName --collection-name $dbCollectionName --resource-group $resourceGroupName"
$result = ExecuteCommand $command $loggingPrefix "Checking if CosmosDB collection exists."
if(!$result) {
    $command = "az cosmosdb collection create --name $dbAccountName --db-name $dbName --collection-name $dbCollectionName --resource-group $resourceGroupName --partition-key-path $dbPartitionKey --throughput $dbThroughput"
    ExecuteCommand $command $loggingPrefix "Creating the Cosmos DB collection."
}

./deploy-apps.ps1 -namePrefix $namePrefix -region $region

D "Deployed the microservice." $loggingPrefix