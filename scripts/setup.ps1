$currentDirectory = Get-Location

Set-Location "$PSSCriptRoot"

$location = Get-Location

. ./functions.ps1

./configure-env.ps1

$namePrefix = $Env:namePrefix
$region = $Env:region
$userName = $Env:userName
$password = $Env:password
$tenantId = $Env:tenantId

$solutionName = $Env:solutionName
$microserviceName = $Env:microserviceName
$apiPort = $Env:apiPort
$workerPort = $Env:workerPort

$loggingPrefix = "$namePrefix $microserviceName Setup"

Set-Location "$location/../$microserviceName/api"
ExecuteCommand "func azure functionapp fetch-app-settings $namePrefix-$microserviceName-api" $loggingPrefix "Fetching the API app settings from azure."
ExecuteCommand "func settings add ""FUNCTIONS_WORKER_RUNTIME"" ""dotnet""" $loggingPrefix "Adding the API run time setting for 'dotnet'."
ExecuteCommand "func settings add ""Host.LocalHttpPort"" ""$apiPort""" $loggingPrefix "Adding the worker run time port setting for '$apiPort'."

Set-Location "$location/../$microserviceName/worker"
ExecuteCommand "func azure functionapp fetch-app-settings $namePrefix-$microserviceName-worker" $loggingPrefix "Fetching the worker app settings from azure."
ExecuteCommand "func settings add ""FUNCTIONS_WORKER_RUNTIME"" ""dotnet""" $loggingPrefix "Adding the worker run time setting for 'dotnet'."
ExecuteCommand "func settings add ""Host.LocalHttpPort"" ""$workerPort""" $loggingPrefix "Adding the worker run time port setting for '$workerPort'."

Set-Location $currentDirectory
