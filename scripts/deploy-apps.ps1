param(  
    [Alias("v")]
    [String] $verbosity
)
$currentDirectory = Get-Location

Set-Location "$PSScriptRoot/../"

. ./scripts/functions.ps1

./scripts/configure-env.ps1

$location = Get-Location

$namePrefix = $Env:namePrefix
$solutionName = $Env:solutionName
$microserviceName = $Env:microserviceName
$apiPort = $Env:apiPort
$workerPort = $Env:workerPort
$userName = $Env:userName
$password = $Env:password
$tenantId = $Env:tenantId
$uniqueDeveloperId = $Env:uniqueDeveloperId
$region = $Env:region

$loggingPrefix = "$namePrefix $microserviceName Deploy Apps"

D "Deploying the applications." $loggingPrefix

$resourceGroupName = "$namePrefix-$microserviceName".ToLower()
$apiName = "$namePrefix-$microserviceName-api".ToLower()
$apiFilePath = "$location/$microserviceName/.dist/$solutionName.$microserviceName.Api.zip"
$workerName = "$namePrefix-$microserviceName-worker".ToLower()
$workerFilePath = "$location/$microserviceName/.dist/$solutionName.$microserviceName.WorkerApi.zip"

Set-Location "$PSSCriptRoot"

$old_ErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

# https://github.com/Microsoft/azure-pipelines-agent/issues/1816
$command = "az"
$result = ExecuteCommand $command $loggingPrefix "Executing first AZ call to get around Task bug."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

$ErrorActionPreference = $old_ErrorActionPreference 

$command = "az login --service-principal --username $userName --password $password --tenant $tenantId"
$result = ExecuteCommand $command $loggingPrefix "Logging in to the Azure CLI."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

$old_ErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

$command = "az webapp deployment source config-zip --resource-group $resourceGroupName --name $apiName --src $apiFilePath"
$result = ExecuteCommand $command $loggingPrefix "Deploying the API application."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

$command = "az webapp deployment source config-zip --resource-group $resourceGroupName --name $workerName --src $workerFilePath"
$result = ExecuteCommand $command $loggingPrefix "Deploying the worker application."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

$ErrorActionPreference = $old_ErrorActionPreference 
D "Finished deploying the applications." $loggingPrefix
Set-Location $currentDirectory