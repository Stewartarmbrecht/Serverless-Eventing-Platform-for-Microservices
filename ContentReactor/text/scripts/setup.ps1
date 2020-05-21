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

if(!$systemName) {
    $systemName = Read-Host -Prompt 'Please provide a prefix to add to the beginning of every resource.  Some resources require globally unique names.  This prefix should guarantee that.'
}
if(!$region) {
    $region = Read-Host -Prompt 'Please provide a region to deploy to.  Hint: WestUS2'
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

$location = Get-Location

$microserviceName = "Text"
$loggingPrefix = "$microserviceName Build"

Set-Location "$PSSCriptRoot/../"

. ./../scripts/functions.ps1

$directoryStart = Get-Location

Set-Location "$directoryStart/src/ContentReactor.$microserviceName/ContentReactor.$microserviceName.Api"
$result = ExecuteCommand "func azure functionapp fetch-app-settings $systemName-text-api" $loggingPrefix "Fetching the API app settings from azure."
$result = ExecuteCommand "func settings add ""FUNCTIONS_WORKER_RUNTIME"" ""dotnet""" $loggingPrefix "Adding the API run time setting for 'dotnet'."
$result = ExecuteCommand "func settings add ""Host.LocalHttpPort"" ""7077""" $loggingPrefix "Adding the worker run time port setting for '7073'."

Set-Location "$directoryStart/src/ContentReactor.$microserviceName/ContentReactor.$microserviceName.Tests.E2E"
$result = ExecuteCommand "npm install" $loggingPrefix "Installing E2E Project."

Set-Location $location
