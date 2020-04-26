param(  
    [Alias("v")]
    [String] $verbosity
)
. ./../scripts/functions.ps1

./../scripts/configure-env.ps1

$systemName = $Env:systemName
$userName = $Env:userName
$password = $Env:password
$tenantId = $Env:tenantId
$region = $Env:region

$loggingPrefix = "$systemName $microserviceName Post Deploy"

$currentDirectory = Get-Location

Set-Location "$PSScriptRoot"

D "Executing post deployment actions." $loggingPrefix

$resourceGroupName = "$systemName-categories"
$dbAccountName="$systemName-categories-db"
$dbName="Categories"
$dbCollectionName="Categories"
$dbPartitionKey="/userId"
$dbThroughput = 400

$old_ErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

# https://github.com/Microsoft/azure-pipelines-agent/issues/1816
$command = "az"
$result = ExecuteCommand $command $loggingPrefix "Executing first AZ call to get around Task bug."

$ErrorActionPreference = $old_ErrorActionPreference 

$command = "az login --service-principal --username $userName --password $password --tenant $tenantId"
$result = ExecuteCommand $command $loggingPrefix "Logging in the Azure CLI"

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

D "Finished the post deployment actions." $loggingPrefix
