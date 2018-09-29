param([String] $namePrefix, [String] $region, [String]$userName, [String] $password)
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
$loggingPrefix = "Images Deployment ($namePrefix)"
$resourceGroupName = "$namePrefix-images"
$deploymentFile = "./microservice.json"
$storageAccountName = "$($namePrefix)imagesblob"
$storageContainerFullImagesName = "fullimages"
$storageContainerPreviewImagesName = "previewimages"
$eventsResourceGroupName = "$namePrefix-events"
$eventsSubscriptionDeploymentFile = "./eventGridSubscriptions-images.json"
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

$command = "az group deployment create -g $resourceGroupName --template-file $deploymentFile --mode Complete --parameters uniqueResourceNamePrefix=$namePrefix"
$result = ExecuteCommand $command $loggingPrefix "Deploying the infrastructure."

$command = "az storage container create --account-name $storageAccountName --name $storageContainerFullImagesName"
$result = ExecuteCommand $command $loggingPrefix "Creating the full image stoarge container."

$command = "az storage container create --account-name $storageAccountName --name $storageContainerPreviewImagesName"
$result = ExecuteCommand $command $loggingPrefix "Creating the preview image stoarge container."

$command = "az storage cors clear --account-name $storageAccountName --services b"
$result = ExecuteCommand $command $loggingPrefix "Clearing the storage account CORS policy."

$command = "az storage cors add --account-name $storageAccountName --services b --methods POST GET PUT --origins ""*"" --allowed-headers ""*"" --exposed-headers ""*"""
$result = ExecuteCommand $command $loggingPrefix "Creating the storage account CORS policy."

./deploy-apps.ps1 -namePrefix $namePrefix -region $region

$command = "az group deployment create -g $eventsResourceGroupName --template-file $eventsSubscriptionDeploymentFile --parameters $eventsSubscriptionParameters"
$result = ExecuteCommand $command $loggingPrefix "Deploying the event grid subscription."

D "Deployed the microservice." $loggingPrefix