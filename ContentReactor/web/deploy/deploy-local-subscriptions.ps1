param([string] $publicUrlToLocalWebServer), [String] $systemName, [String] $userName, [String] $password, [String] $tenantId, [string] $uniqueDeveloperId
if (!$systemName) {
    $systemName = $Env:systemName
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

if(!$systemName) {
    $systemName = Read-Host -Prompt 'Please provide a prefix to add to the beginning of every resource.  Some resources require globally unique names.  This prefix should guarantee that.'
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

$loggingPrefix = "Web Server Subcriptions ($systemName)"
$eventsResourceGroupName = "$systemName-events"

Set-Location "$PSSCriptRoot"

. ./../../scripts/functions.ps1

$directoryStart = Get-Location

if (!$systemName) {
    D "Either pass in the '-systemName' parameter when calling this script or 
    set and environment variable with the name: 'systemName'." $loggingPrefix
}

D "Deploying the web server subscriptions." $loggingPrefix

$old_ErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

# https://github.com/Microsoft/azure-pipelines-agent/issues/1816
$command = "az"
$result = ExecuteCommand $command $loggingPrefix "Executing first AZ call to get around Task bug."

$ErrorActionPreference = $old_ErrorActionPreference 

$command = "az login --service-principal --username $userName --password $password --tenant $tenantId"
$result = ExecuteCommand $command $loggingPrefix "Logging in the Azure CLI"

$command = "az group deployment create -g $eventsResourceGroupName --template-file ./eventGridSubscriptions-web.local.json --parameters uniqueResourcesystemName=$systemName publicUrlToLocalWebServer=$publicUrlToLocalWebServer uniqueDeveloperId=$uniqueDeveloperId"
$result = ExecuteCommand $command $loggingPrefix "Deploying the event grid subscription."

D "Deployed the subscriptions." $loggingPrefix