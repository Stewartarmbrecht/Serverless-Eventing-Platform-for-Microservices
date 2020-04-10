param([String] $namePrefix, [String] $region, [String] $userName, [String] $password, [String] $tenantId)
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
if (!$tenantId) {
    $tenantId = $Env:tenantId
}

if(!$namePrefix) {
    $namePrefix = Read-Host -Prompt 'Please provide a prefix to add to the beginning of every resource.  Some resources require globally unique names.  This prefix should guarantee that.'
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

$microserviceName = "Audio"
$loggingPrefix = "$microserviceName Build"
$apiPort = 7073
$workerPort = 7074

Set-Location "$PSSCriptRoot/../"

. ./../scripts/functions.ps1

$directoryStart = Get-Location

Set-Location "$directoryStart/src/ContentReactor.$microserviceName/ContentReactor.$microserviceName.Api"
ExecuteCommand "func azure functionapp fetch-app-settings $namePrefix-$microserviceName-api" $loggingPrefix "Fetching the API app settings from azure."
ExecuteCommand "func settings add ""FUNCTIONS_WORKER_RUNTIME"" ""dotnet""" $loggingPrefix "Adding the API run time setting for 'dotnet'."
ExecuteCommand "func settings add ""Host.LocalHttpPort"" ""$apiPort""" $loggingPrefix "Adding the worker run time port setting for '$apiPort'."

Set-Location "$directoryStart/src/ContentReactor.$microserviceName/ContentReactor.$microserviceName.WorkerApi"
ExecuteCommand "func azure functionapp fetch-app-settings $namePrefix-$microserviceName-worker" $loggingPrefix "Fetching the worker app settings from azure."
ExecuteCommand "func settings add ""FUNCTIONS_WORKER_RUNTIME"" ""dotnet""" $loggingPrefix "Adding the worker run time setting for 'dotnet'."
ExecuteCommand "func settings add ""Host.LocalHttpPort"" ""$workerPort""" $loggingPrefix "Adding the worker run time port setting for '$workerPort'."

Set-Location $location
