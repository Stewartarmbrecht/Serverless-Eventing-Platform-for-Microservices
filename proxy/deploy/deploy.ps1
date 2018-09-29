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
$loggingPrefix = "Proxy Deployment ($namePrefix)"
$resourceGroupName = "$namePrefix-proxy"
$deploymentFile = "./template.json"

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

./deploy-apps.ps1 -namePrefix $namePrefix -region $region

D "Deployed the microservice." $loggingPrefix