param([String]$namePrefix,[String]$region)
if (!$namePrefix) {
    $namePrefix = $Env:namePrefix
}
if (!$region) {
    $region = $Env:region
}
$loggingPrefix = "Audio Deployment ($namePrefix)"
$resourceGroupName = "$namePrefix-audio"
$deploymentFile = "./microservice.json"
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

$command = "az group deployment create -g $resourceGroupName --template-file $deploymentFile --parameters $deploymentParameters --mode Complete"
ExecuteCommand $command $loggingPrefix "Deploying the infrastructure."

$command = "az storage container create --account-name $storageAccountName --name $storageContainerName"
ExecuteCommand $command $loggingPrefix "Creating the stoarge container."

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
