param([String]$namePrefix,[String]$region,[String]$bigHugeThesaurusApiKey)
$resourceGroupName = "$namePrefix-categories"
$deploymentFile = ".\microservice.json"
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

function D([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourceGroupName Deployment: $value"  -ForegroundColor DarkCyan }
function E([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourceGroupName Deployment: $value"  -ForegroundColor DarkRed }

# Categories Microservice Deploy

D("Setting location to the scripts folder")
Set-Location $PSSCriptRoot

D("Creating the $resourceGroupName resource group in the $region region.")
az group create -n $resourceGroupName -l $region
D("Created the $resourceGroupName resource group in the $region region.")

D("Executing the $resourceGroupName deployment.")
D("`tUsing file: $deploymentFile")
D("`tUsing parameters: $deploymentParameters")
D("az group deployment create -g $resourceGroupName --template-file $deploymentFile --mode Complete --parameters $deploymentParameters")
az group deployment create -g $resourceGroupName --template-file $deploymentFile --mode Complete --parameters uniqueResourceNamePrefix=$namePrefix bigHugeThesaurusApiKey=$bigHugeThesaurusApiKey
D("Executed the $resourceGroupName deployment.")

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

D("Deploying $resourceGroupName worker function:")
D("`tUsing name: $workerName")
D("`tUsing file path: $workerFilePath")
az webapp deployment source config-zip --resource-group $resourceGroupName --name $workerName --src $workerFilePath
D("Deployed $resourceGroupName worker function:")
D("`tUsing name: $workerName")
D("`tUsing file path: $workerFilePath")

D("Deploying $resourceGroupName event grid subscription to event grid in $eventsResourceGroupName.")
D("`tUsing file path: $eventsSubscriptionDeploymentFile")
D("`tUsing parameters: $eventsSubscriptionParameters")
az group deployment create -g $eventsResourceGroupName --template-file $eventsSubscriptionDeploymentFile --parameters "$eventsSubscriptionParameters"
D("Deployed $resourceGroupName event grid subscription to event grid in $eventsResourceGroupName.")
D("`tUsing file path: $eventsSubscriptionDeploymentFile")
D("`tUsing parameters: $eventsSubscriptionParameters")

D("Completed $resourceGroupName deployment..")