param([String] $systemName, [String] $region, [String] $userName, [String] $password, [String] $tenantId)
if (!$systemName) {
    $systemName = $Env:systemName
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
if (!$tenantId) {
    $tenantId = $Env:tenantId
}

$loggingPrefix = "Proxy Deployment ($systemName)"
$resourceGroupName = "$systemName-proxy"
$apiName = "$systemName-proxy-api"
$apiFilePath = "./ContentReactor.Proxy.Api.zip"

Set-Location "$PSSCriptRoot"

. ./../../scripts/functions.ps1

if (!$systemName) {
    D "Either pass in the '-systemName' parameter when calling this script or 
    set and environment variable with the name: 'systemName'." $loggingPrefix
}
if (!$region) {
    D "Either pass in the '-region' parameter when calling this script or 
    set and environment variable with the name: 'region'." $loggingPrefix
}

$old_ErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

# https://github.com/Microsoft/azure-pipelines-agent/issues/1816
$command = "az"
$result = ExecuteCommand $command $loggingPrefix "Executing first AZ call to get around Task bug."

$ErrorActionPreference = $old_ErrorActionPreference 

$command = "az login --service-principal --username $userName --password $password --tenant $tenantId"
$result = ExecuteCommand $command $loggingPrefix "Logging in the Azure CLI"

$old_ErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

$command = "az webapp deployment source config-zip --resource-group $resourceGroupName --name $apiName --src $apiFilePath"
$result = ExecuteCommand $command $loggingPrefix "Deploying the API application."

$ErrorActionPreference = $old_ErrorActionPreference 
