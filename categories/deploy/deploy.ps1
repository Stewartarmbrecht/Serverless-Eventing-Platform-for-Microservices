param([String] $namePrefix, [String] $region, [String] $bigHugeThesaurusApiKey, [String]$userName, [String] $password, [String] $tenantId)
if (!$namePrefix) {
    $namePrefix = $Env:namePrefix
}
if (!$region) {
    $region = $Env:region
}
if (!$bigHugeThesaurusApiKey) {
    $bigHugeThesaurusApiKey = $Env:bigHugeThesaurusApiKey
}
if (!$userName) {
    $userName = $Env:userName
}
if (!$password) {
    $password = $Env:password
}
if (!$tenantId) {
    $tenantId = $Env:tenantId
}

$loggingPrefix = "Categories Deployment ($namePrefix)"
$resourceGroupName = "$namePrefix-categories"
$deploymentFile = "./microservice.json"
$dbAccountName="$namePrefix-categories-db"
$dbName="Categories"
$dbCollectionName="Categories"
$dbPartitionKey="/userId"
$dbThroughput = 400
$eventsResourceGroupName = "$namePrefix-events"
$eventsSubscriptionDeploymentFile = "./eventGridSubscriptions-categories.json"
$eventsSubscriptionParameters="uniqueResourceNamePrefix=$namePrefix"

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

$old_ErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

# https://github.com/Microsoft/azure-pipelines-agent/issues/1816
$command = "az"
$result = ExecuteCommand $command $loggingPrefix "Executing first AZ call to get around Task bug."

$ErrorActionPreference = $old_ErrorActionPreference 

$command = "az login --service-principal --username $userName --password $password --tenant $tenantId"
$result = ExecuteCommand $command $loggingPrefix "Logging in the Azure CLI"

$command = "az group create -n $resourceGroupName -l $region"
$result = ExecuteCommand $command $loggingPrefix "Creating the resource group."

$command = "az group deployment create -g $resourceGroupName --template-file $deploymentFile --mode Complete --parameters uniqueResourceNamePrefix=$namePrefix bigHugeThesaurusApiKey=$bigHugeThesaurusApiKey"
$result = ExecuteCommand $command $loggingPrefix "Deploying the infrastructure."

$command = "az cosmosdb database exists --name $dbAccountName --db-name $dbName --resource-group $resourceGroupName"
$result = ExecuteCommand $command $loggingPrefix "Checking if CosmosDB exists."
if($result -eq $false) {
    $command = "az cosmosdb database create --name $dbAccountName --db-name $dbName --resource-group $resourceGroupName"
    $result = ExecuteCommand $command $loggingPrefix "Creating the Cosmos DB database."
}

$command = "az cosmosdb collection exists --name $dbAccountName --db-name $dbName --collection-name $dbCollectionName --resource-group $resourceGroupName"
$result = ExecuteCommand $command $loggingPrefix "Checking if CosmosDB collection exists."
if($result -eq $false) {
    $command = "az cosmosdb collection create --name $dbAccountName --db-name $dbName --collection-name $dbCollectionName --resource-group $resourceGroupName --partition-key-path $dbPartitionKey --throughput $dbThroughput"
    $result = ExecuteCommand $command $loggingPrefix "Creating the Cosmos DB collection."
}

./deploy-apps.ps1 -namePrefix $namePrefix -region $region

$command = "az group deployment create -g $eventsResourceGroupName --template-file $eventsSubscriptionDeploymentFile --parameters $eventsSubscriptionParameters"
$result = ExecuteCommand $command $loggingPrefix "Deploying the event grid subscription."

D "Deployed the microservice." $loggingPrefix
