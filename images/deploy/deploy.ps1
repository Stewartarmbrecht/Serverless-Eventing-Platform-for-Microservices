param([String]$namePrefix,[String]$region)
if (!$namePrefix) {
    $namePrefix = $Env:namePrefix
}
if (!$region) {
    $region = $Env:region
}
$loggingPrefix = "Images Deployment ($namePrefix)"
$resourceGroupName = "$namePrefix-images"
$deploymentFile = "./microservice.json"
$storageAccountName = "$($namePrefix)imagesblob"
$storageContainerFullImagesName = "fullimages"
$storageContainerPreviewImagesName = "previewimages"
$apiName = "$namePrefix-images-api"
$apiFilePath = "./ContentReactor.Images.Api.zip"
$workerName = "$namePrefix-images-worker"
$workerFilePath = "./ContentReactor.Images.WorkerApi.zip"
$eventsResourceGroupName = "$namePrefix-events"
$eventsSubscriptionDeploymentFile = "./eventGridSubscriptions-images.json"
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

$command = "az group deployment create -g $resourceGroupName --template-file $deploymentFile --mode Complete --parameters uniqueResourceNamePrefix=$namePrefix"
ExecuteCommand $command $loggingPrefix "Deploying the infrastructure."

$command = "az storage container create --account-name $storageAccountName --name $storageContainerFullImagesName"
ExecuteCommand $command $loggingPrefix "Creating the full image stoarge container."

$command = "az storage container create --account-name $storageAccountName --name $storageContainerPreviewImagesName"
ExecuteCommand $command $loggingPrefix "Creating the preview image stoarge container."

$command = "az storage cors clear --account-name $storageAccountName --services b"
ExecuteCommand $command $loggingPrefix "Clearing the storage account CORS policy."

$command = "az storage cors add --account-name $storageAccountName --services b --methods POST GET PUT --origins ""*"" --allowed-headers ""*"" --exposed-headers ""*"""
ExecuteCommand $command $loggingPrefix "Creating the storage account CORS policy."

$command = "az webapp deployment source config-zip --resource-group $resourceGroupName --name $apiName --src $apiFilePath"
ExecuteCommand $command $loggingPrefix "Deploying the API application."

$command = "az webapp deployment source config-zip --resource-group $resourceGroupName --name $workerName --src $workerFilePath"
ExecuteCommand $command $loggingPrefix "Deploying the worker application."

$command = "az group deployment create -g $eventsResourceGroupName --template-file $eventsSubscriptionDeploymentFile --parameters $eventsSubscriptionParameters"
ExecuteCommand $command $loggingPrefix "Deploying the event grid subscription."

D "Completed $resourceGroupName deployment." $loggingPrefix


