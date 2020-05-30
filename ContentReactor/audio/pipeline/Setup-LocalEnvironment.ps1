[CmdletBinding()]
param()

$currentDirectory = Get-Location
Set-Location $PSSCriptRoot

. ./Functions.ps1

./Configure-Environment.ps1

$instanceName = $Env:InstanceName
$region = $Env:Region
$userName = $Env:UserName
$password = $Env:Password
$tenantId = $Env:TenantId

$apiPort = $Env:AudioApiPort
$workerPort = $Env:AudioWorkerPort

$loggingPrefix = "ContentReactor Audio $instanceName Setup"

Set-Location "./../api"
Invoke-BuildCommand "func azure functionapp fetch-app-settings $instanceName-audio-api" $loggingPrefix "Fetching the API app settings from azure."
Invoke-BuildCommand "func settings add ""FUNCTIONS_WORKER_RUNTIME"" ""dotnet""" $loggingPrefix "Adding the API run time setting for 'dotnet'."
Invoke-BuildCommand "func settings add ""Host.LocalHttpPort"" ""$apiPort""" $loggingPrefix "Adding the worker run time port setting for '$apiPort'."

Set-Location "./../worker"
Invoke-BuildCommand "func azure functionapp fetch-app-settings $instanceName-audio-worker" $loggingPrefix "Fetching the worker app settings from azure."
Invoke-BuildCommand "func settings add ""FUNCTIONS_WORKER_RUNTIME"" ""dotnet""" $loggingPrefix "Adding the worker run time setting for 'dotnet'."
Invoke-BuildCommand "func settings add ""Host.LocalHttpPort"" ""$workerPort""" $loggingPrefix "Adding the worker run time port setting for '$workerPort'."

Set-Location $currentDirectory
