param([String]$namePrefix,[String]$region,[String]$bigHugeThesaurusApiKey)
if (!$namePrefix) {
    $namePrefix = $Env:namePrefix
}
if (!$region) {
    $region = $Env:region
}
if (!$bigHugeThesaurusApiKey) {
    $bigHugeThesaurusApiKey = $Env:bigHugeThesaurusApiKey
}
$loggingPrefix = "Categories Deployment ($namePrefix)"
$resourceGroupName = "$namePrefix-categories"
$deploymentFile = "./microservice.json"
$deploymentParameters = "'uniqueResourceNamePrefix=$namePrefix' 'bigHugeThesaurusApiKey=$bigHugeThesaurusApiKey'"
$dbAccountName="$namePrefix-categories-db"
$dbName="Categories"
$dbCollectionName="Categories"
$dbPartitionKey="/userId"
$dbThroughput = 400
$apiName = "$namePrefix-categories-api"
$apiFilePath = "./ContentReactor.Categories.Api.zip"
$workerName = "$namePrefix-categories-worker"
$workerFilePath = "./ContentReactor.Categories.WorkerApi.zip"
$eventsResourceGroupName = "$namePrefix-events"
$eventsSubscriptionDeploymentFile = "./eventGridSubscriptions-categories.json"
$eventsSubscriptionParameters="uniqueResourceNamePrefix=$namePrefix"

Set-Location "$PSSCriptRoot"

. ./../../scripts/functions.ps1

$directoryStart = Get-Location

if (!$namePrefix) {
    D "Either pass in the '-namePrefix' parameter when calling this script or 
    set and environment variable with the name: 'namePrefix'." $loggingPrefix
}
if (!$region) {
    D "Either pass in the '-region' parameter when calling this script or 
    set and environment variable with the name: 'region'." $loggingPrefix
}
# Audio Microservice Deploy

D "Deploying the microservice." $loggingPrefix

$command = "az group create -n $resourceGroupName -l $region"
ExecuteCommand $command $loggingPrefix "Creating the resource group."

$command = "az group deployment create -g $resourceGroupName --template-file $deploymentFile --mode Complete --parameters uniqueResourceNamePrefix=$namePrefix bigHugeThesaurusApiKey=$bigHugeThesaurusApiKey"
ExecuteCommand $command $loggingPrefix "Deploying the infrastructure."

$command = "az cosmosdb database create --name $dbAccountName --db-name $dbName --resource-group $resourceGroupName"
ExecuteCommand $command $loggingPrefix "Creating the Cosmos DB database."

$command = "az cosmosdb collection create --name $dbAccountName --db-name $dbName --collection-name $dbCollectionName --resource-group $resourceGroupName --partition-key-path $dbPartitionKey --throughput $dbThroughput"
ExecuteCommand $command $loggingPrefix "Creating the Cosmos DB collection."

$command = "az webapp deployment source config-zip --resource-group $resourceGroupName --name $apiName --src $apiFilePath"
ExecuteCommand $command $loggingPrefix "Deploying the API application."

$command = "az webapp deployment source config-zip --resource-group $resourceGroupName --name $workerName --src $workerFilePath"
ExecuteCommand $command $loggingPrefix "Deploying the worker application."

$command = "az group deployment create -g $eventsResourceGroupName --template-file $eventsSubscriptionDeploymentFile --parameters $eventsSubscriptionParameters"
ExecuteCommand $command $loggingPrefix "Deploying the event grid subscription."

D "Completed $resourceGroupName deployment." $loggingPrefix
