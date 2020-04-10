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

$loggingPrefix = "$namePrefix $microserviceName Deploy Subscriptions"

$resourceGroupName = "$namePrefix-$microserviceName".ToLower()
$deploymentFile = "$location/$microserviceName/templates/microservice.json"
$deploymentParameters = "uniqueResourceNamePrefix=$namePrefix"
$storageAccountName = "$($namePrefix)$($microserviceName)blob".ToLower()
$storageContainerName = $microserviceName.ToLower()
$apiName = "$namePrefix-$microserviceName-api".ToLower()
$apiFilePath = "./$microserviceName/.dist/$solutionName.$microserviceName.Api.zip"
$workerName = "$namePrefix-$microserviceName-worker".ToLower()
$workerFilePath = "./$microserviceName/.dist/$solutionName.$microserviceName.WorkerApi.zip"
$eventsResourceGroupName = "$namePrefix-events"
$eventsSubscriptionDeploymentFile = "$location/$microserviceName/templates/eventGridSubscriptions.json".ToLower()
$eventsSubscriptionParameters="uniqueResourceNamePrefix=$namePrefix"

Set-Location "$PSScriptRoot"

D "Deploying the microservice subscriptions." $loggingPrefix

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
$result = ExecuteCommand $command $loggingPrefix "Logging in the Azure CLI"
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

$command = "az group deployment create -g $eventsResourceGroupName --template-file $eventsSubscriptionDeploymentFile --parameters $eventsSubscriptionParameters"
$result = ExecuteCommand $command $loggingPrefix "Deploying the event grid subscription."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

D "Deployed the microservice subscriptions." $loggingPrefix
Set-Location $currentDirectory