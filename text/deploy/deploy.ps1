param([String]$namePrefix,[String]$region)
$resourceGroupName = "$namePrefix-text"
$deploymentFile = ".\microservice.json"
$dbAccountName="$namePrefix-text-db"
$dbName="Text"
$dbCollectionName="Text"
$dbPartitionKey="/userId"
$dbThroughput = 400
$apiName = "$namePrefix-text-api"
$apiFilePath = "./ContentReactor.Text.Api.zip"

function D([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourceGroupName Deployment: $value"  -ForegroundColor DarkCyan }
function E([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourceGroupName Deployment: $value"  -ForegroundColor DarkRed }

# Text Microservice Deploy

D("Setting location to the scripts folder")
Set-Location $PSSCriptRoot

D("Creating the $resourceGroupName resource group in the $region region.")
az group create -n $resourceGroupName -l $region
D("Created the $resourceGroupName resource group in the $region region.")

D("Executing the $resourceGroupName deployment.")
D("`tUsing file: $deploymentFile")
D("`tUsing parameters: uniqueResourceNamePrefix=$namePrefix")
az group deployment create -g $resourceGroupName --template-file $deploymentFile --mode Complete --parameters uniqueResourceNamePrefix=$namePrefix
D("Executed the $resourceGroupName deployment.")
D("`tUsing file: $deploymentFile")
D("`tUsing parameters: uniqueResourceNamePrefix=$namePrefix")

D("Creating $resourceGroupName cosmos db.")
D("`tUsing DB account name: $dbAccountName")
D("`tUsing DB name: $dbName")
az cosmosdb database create --name $dbAccountName --db-name $dbName --resource-group $resourceGroupName
D("Created $resourceGroupName cosmos db.")

D("Creating $resourceGroupName cosmos db collection $dbCollectionName for $dbAccountName in $dbName.")
az cosmosdb collection create --name $dbAccountName --db-name $dbName --collection-name $dbCollectionName `
    --resource-group $resourceGroupName --partition-key-path $dbPartitionKey --throughput $dbThroughput
D("Created $resourceGroupName cosmos db collection $dbCollectionName for $dbAccountName in $dbName.")

D("Deploying $resourceGroupName api function:")
D("`tUsing name: $apiName")
D("`tUsing file path: $apiFilePath")
az webapp deployment source config-zip --resource-group $resourceGroupName --name $apiName --src $apiFilePath
D("Deployed $resourceGroupName api function:")
D("`tUsing name: $apiName")
D("`tUsing file path: $apiFilePath")

D("Completed $resourceGroupName deployment..")