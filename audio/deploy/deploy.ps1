param([String]$namePrefix,[String]$region)
if (!$namePrefix) {
    $namePrefix = $Env:namePrefix
}
if (!$region) {
    $region = $Env:region
}
$resourceGroupName = "$namePrefix-audio"
$deploymentFile = ".\microservice.json"
$deploymentParameters = "uniqueResourceNamePrefix=$namePrefix"
$storageAccountName = "$($namePrefix)audioblob"
$storageContainerName = "audio"
$apiName = "$namePrefix-audio-api"
$apiFilePath = "./ContentReactor.Audio.Api.zip"
$workerName = "$namePrefix-audio-worker"
$workerFilePath = "./ContentReactor.Audio.WorkerApi.zip"
$eventsResourceGroupName = "$namePrefix-events"
$eventsSubscriptionDeploymentFile = "./eventGridSubscriptions-audio.json"
$eventsSubscriptionParameters="uniqueResourceNamePrefix=$namePrefix"

function D([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourceGroupName Deployment: $value"  -ForegroundColor DarkCyan }
function E([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourceGroupName Deployment: $value"  -ForegroundColor DarkRed }

# Audio Microservice Deploy

D("Setting location to the scripts folder")
Set-Location $PSSCriptRoot

D("Creating the $resourceGroupName resource group in the $region region.")
az group create -n $resourceGroupName -l $region
D("Created the $resourceGroupName resource group in the $region region.")

D("Parameters: $deploymentParameters")

D("Executing the $resourceGroupName deployment.")
D("`tUsing file: $deploymentFile")
D("`tUsing parameters: $deploymentParameters")
az group deployment create -g $resourceGroupName --template-file $deploymentFile --parameters $deploymentParameters --mode Complete
D("Executed the $resourceGroupName deployment.")

D("Creating $resourceGroupName storage account container $storageContainerName for $storageAccountName.")
az storage container create --account-name $storageAccountName --name $storageContainerName
D("Created $resourceGroupName storage account container $storageContainerName for $storageAccountName.")

D("Creating $resourceGroupName CORS policy for storage account $storageAccountName.")
az storage cors clear --account-name $storageAccountName --services b
az storage cors add --account-name $storageAccountName --services b --methods POST GET PUT --origins "*" --allowed-headers "*" --exposed-headers "*"
D("Created $resourceGroupName CORS policy for storage account $storageAccountName.")

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
az group deployment create -g $eventsResourceGroupName --template-file $eventsSubscriptionDeploymentFile --parameters $eventsSubscriptionParameters
D("Deployed $resourceGroupName event grid subscription to event grid in $eventsResourceGroupName.")
D("`tUsing file path: $eventsSubscriptionDeploymentFile")
D("`tUsing parameters: $eventsSubscriptionParameters")

D("Completed $resourceGroupName deployment..")
#>