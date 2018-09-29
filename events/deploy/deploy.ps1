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
$loggingPrefix = "Events Deployment ($namePrefix)"
$resourceGroupName = "$namePrefix-events"
$deploymentFile = "./template.json"
$deploymentParameters = "uniqueResourceNamePrefix=$namePrefix"

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

D "Deploying the event grid." $loggingPrefix

$command = "az login -u $userName -p $password"
$result = ExecuteCommand $command $loggingPrefix "Logging in the Azure CLI"

$command = "az group create -n $resourceGroupName -l $region"
$result = ExecuteCommand $command $loggingPrefix "Creating the resource group."

$command = "az group deployment create -g $resourceGroupName --template-file $deploymentFile --parameters $deploymentParameters --mode Complete"
$result = ExecuteCommand $command $loggingPrefix "Deploying the infrastructure."

D "Completed the event grid deployment." $loggingPrefix
