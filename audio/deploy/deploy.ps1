param([String]$namePrefix,[String]$region, [String]$userName, [String] $password)
if (!$namePrefix) {
    $namePrefix = $Env:namePrefix
}
if (!$region) {
    $region = $Env:region
}
if (!$userName) {
    $userName = $Env:userName
}
if (!$password) {
    $password = $Env:password
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

if (!$namePrefix) {
    D "Either pass in the '-namePrefix' parameter when calling this script or 
    set and environment variable with the name: 'namePrefix'." $loggingPrefix
}
if (!$region) {
    D "Either pass in the '-region' parameter when calling this script or 
    set and environment variable with the name: 'region'." $loggingPrefix
}

D "Deploying the microservice." $loggingPrefix

$command = "az login -u $userName -p $password"
$result = ExecuteCommand $command $loggingPrefix "Logging in the Azure CLI"

$command = "az group create -n $resourceGroupName -l $region"
$result = ExecuteCommand $command $loggingPrefix "Creating the resource group."

$command = "az group deployment create -g $resourceGroupName --template-file $deploymentFile --parameters $deploymentParameters --mode Complete"
$result = ExecuteCommand $command $loggingPrefix "Deploying the infrastructure."

$command = "az storage container create --account-name $storageAccountName --name $storageContainerName"
$result = ExecuteCommand $command $loggingPrefix "Creating the stoarge container."

$command = "az storage cors clear --account-name $storageAccountName --services b"
$result = ExecuteCommand $command $loggingPrefix "Clearing the storage account CORS policy."

$command = "az storage cors add --account-name $storageAccountName --services b --methods POST GET PUT --origins ""*"" --allowed-headers ""*"" --exposed-headers ""*"""
$result = ExecuteCommand $command $loggingPrefix "Creating the storage account CORS policy."

./deploy-apps.ps1 -namePrefix $namePrefix -region $region

$command = "az group deployment create -g $eventsResourceGroupName --template-file $eventsSubscriptionDeploymentFile --parameters $eventsSubscriptionParameters"
$result = ExecuteCommand $command $loggingPrefix "Deploying the event grid subscription."

D "Deployed the microservice." $loggingPrefix
