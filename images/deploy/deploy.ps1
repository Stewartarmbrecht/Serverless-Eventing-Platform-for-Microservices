param([String]$namePrefix,[String]$region)
$resourceGroupName = "$namePrefix-images"
$deploymentFile = ".\microservice.json"
$storageAccountName = "$($namePrefix)imagesblob"
$storageContainerFullImagesName = "fullimages"
$storageContainerPreviewImagesName = "previewimages"
$apiName = "$namePrefix-images-api"
$apiFilePath = "./ContentReactor.Images.Api.zip"
$workerName = "$namePrefix-images-worker"
$workerFilePath = "./ContentReactor.Images.WorkerApi.zip"
$eventsResourceGroupName = "$namePrefix-events"
$eventsSubscriptionDeploymentFile = "./eventGridSubscriptions-images.json"

function D([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourceGroupName Deployment: $value"  -ForegroundColor DarkCyan }
function E([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourceGroupName Deployment: $value"  -ForegroundColor DarkRed }

# Images Microservice Deploy

D("Setting location to the scripts folder")
Set-Location $PSSCriptRoot

D("Creating the $resourceGroupName resource group in the $region region.")
az group create -n $resourceGroupName -l $region
D("Created the $resourceGroupName resource group in the $region region.")

D("Parameters: $deploymentParameters")

D("Executing the $resourceGroupName deployment.")
D("`tUsing file: $deploymentFile")
D("`tUsing parameters: uniqueResourceNamePrefix=$namePrefix")
az group deployment create -g $resourceGroupName --template-file $deploymentFile --mode Complete --parameters uniqueResourceNamePrefix=$namePrefix
D("Executed the $resourceGroupName deployment.")
D("`tUsing file: $deploymentFile")
D("`tUsing parameters: uniqueResourceNamePrefix=$namePrefix")

D("Creating $resourceGroupName storage account container $storageContainerFullImagesName for $storageAccountName.")
az storage container create --account-name $storageAccountName --name $storageContainerFullImagesName
D("Created $resourceGroupName storage account container $storageContainerFullImagesName for $storageAccountName.")

D("Creating $resourceGroupName storage account container $storageContainerPreviewImagesName for $storageAccountName.")
az storage container create --account-name $storageAccountName --name $storageContainerPreviewImagesName
D("Created $resourceGroupName storage account container $storageContainerPreviewImagesName for $storageAccountName.")

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
D("`tUsing parameters: uniqueResourceNamePrefix=$namePrefix")
az group deployment create -g $eventsResourceGroupName --template-file $eventsSubscriptionDeploymentFile --parameters uniqueResourceNamePrefix=$namePrefix
D("Deployed $resourceGroupName event grid subscription to event grid in $eventsResourceGroupName.")
D("`tUsing file path: $eventsSubscriptionDeploymentFile")
D("`tUsing parameters: uniqueResourceNamePrefix=$namePrefix")

D("Completed $resourceGroupName deployment..")