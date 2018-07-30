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

. ./../../scripts/ContentReactor-Functions.ps1

$directoryStart = Get-Location
D "directoryStart: $directoryStart" $loggingPrefix

if (!$namePrefix) {
    D "Either pass in the '-namePrefix' parameter when calling this script or 
    set and environment variable with the name: 'namePrefix'." $resourceGroupName
}
if (!$region) {
    D "Either pass in the '-region' parameter when calling this script or 
    set and environment variable with the name: 'region'." $resourceGroupName
}
# Audio Microservice Deploy

$command = "az group create -n $resourceGroupName -l $region"
ExecuteCommand $command $resourceGroupName

$command = "az group deployment create -g $resourceGroupName --template-file $deploymentFile --parameters $deploymentParameters --mode Complete"
ExecuteCommand $command $loggingPrefix

$command = "az storage container create --account-name $storageAccountName --name $storageContainerName"
ExecuteCommand $command $loggingPrefix

$command = "az storage cors clear --account-name $storageAccountName --services b"
ExecuteCommand $command $loggingPrefix

$command = "az storage cors add --account-name $storageAccountName --services b --methods POST GET PUT --origins ""*"" --allowed-headers ""*"" --exposed-headers ""*"""
ExecuteCommand $command $loggingPrefix

$command = "az webapp deployment source config-zip --resource-group $resourceGroupName --name $apiName --src $apiFilePath"
ExecuteCommand $command $loggingPrefix

$command = "az webapp deployment source config-zip --resource-group $resourceGroupName --name $workerName --src $workerFilePath"
ExecuteCommand $command $loggingPrefix

$command = "az group deployment create -g $eventsResourceGroupName --template-file $eventsSubscriptionDeploymentFile --parameters $eventsSubscriptionParameters"
ExecuteCommand $command $loggingPrefix

D "Completed $resourceGroupName deployment." $resourceGroupName