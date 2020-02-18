param([string] $publicUrlToLocalWebServer), [String] $namePrefix, [String] $userName, [String] $password, [String] $tenantId, [string] $uniqueDeveloperId
if (!$namePrefix) {
    $namePrefix = $Env:namePrefix
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
if (!$publicUrlToLocalWebServer) {
    $publicUrlToLocalWebServer = $Env:publicUrlToLocalWebServer
}
if (!$uniqueDeveloperId) {
    $uniqueDeveloperId = $Env:uniqueDeveloperId
}

if(!$namePrefix) {
    $namePrefix = Read-Host -Prompt 'Please provide a prefix to add to the beginning of every resource.  Some resources require globally unique names.  This prefix should guarantee that.'
}
if(!$userName) {
    $userName = Read-Host -Prompt 'Please provide the Application (client) ID for a service principle to use for the deployment.'
}
if(!$password) {
    $password = Read-Host -Prompt 'Please provide the service principal secret (password) to use for the deployment.'
}
if(!$tenantId) {
    $tenantId = Read-Host -Prompt 'Please provide the Directory (tenant) ID for the service principal.'
}
if(!$publicUrlToLocalWebServer) {
    $publicUrlToLocalWebServer = Read-Host -Prompt 'Please provide the public url to the local web server.'
}
if(!$uniqueDeveloperId) {
    $uniqueDeveloperId = Read-Host -Prompt 'Please provide a unique identifier for the developer to identify subscriptionbs deployed in the cloud.'
}

$loggingPrefix = "Images Worker Subcriptions ($namePrefix)"
$eventsResourceGroupName = "$namePrefix-events"

Set-Location "$PSSCriptRoot"

. ./../../scripts/functions.ps1

$directoryStart = Get-Location

if (!$namePrefix) {
    D "Either pass in the '-namePrefix' parameter when calling this script or 
    set and environment variable with the name: 'namePrefix'." $loggingPrefix
}

D "Deploying the worker service subscriptions." $loggingPrefix

$old_ErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

# https://github.com/Microsoft/azure-pipelines-agent/issues/1816
$command = "az"
$result = ExecuteCommand $command $loggingPrefix "Executing first AZ call to get around Task bug."

$ErrorActionPreference = $old_ErrorActionPreference 

$command = "az login --service-principal --username $userName --password $password --tenant $tenantId"
$result = ExecuteCommand $command $loggingPrefix "Logging in the Azure CLI"

$command = "az group deployment create -g $eventsResourceGroupName --template-file ./eventGridSubscriptions-images.local.json --parameters uniqueResourceNamePrefix=$namePrefix publicUrlToLocalWebServer=$publicUrlToLocalWebServer uniqueDeveloperId=$uniqueDeveloperId"
$result = ExecuteCommand $command $loggingPrefix "Deploying the event grid subscription."

D "Deployed the subscriptions." $loggingPrefix