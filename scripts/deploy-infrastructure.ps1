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

$loggingPrefix = "$namePrefix $microserviceName Deploy Infrastructure"

$resourceGroupName = "$namePrefix-$microserviceName".ToLower()
$deploymentFile = "$location/$microserviceName/templates/microservice.json"
$deploymentParameters = "uniqueResourceNamePrefix=$namePrefix"
$storageAccountName = "$($namePrefix)$($microserviceName)blob".ToLower()
$storageContainerName = $microserviceName.ToLower()
$apiName = "$namePrefix-$microserviceName-api".ToLower()
$apiFilePath = "$location/$microserviceName/.dist/$solutionName.$microserviceName.Api.zip"
$workerName = "$namePrefix-$microserviceName-worker".ToLower()
$workerFilePath = "$location/$microserviceName/.dist/$solutionName.$microserviceName.WorkerApi.zip"
$eventsResourceGroupName = "$namePrefix-events"
$eventsSubscriptionDeploymentFile = "$location/$microserviceName/templates/eventGridSubscriptions-$microserviceName.json".ToLower()
$eventsSubscriptionParameters="uniqueResourceNamePrefix=$namePrefix"

D "Deploying the microservice infrastructure." $loggingPrefix

$old_ErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

# https://github.com/Microsoft/azure-pipelines-agent/issues/1816
$command = "az"
$result = ExecuteCommand $command $loggingPrefix "Executing first AZ call to get around Task bug."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}cd 

$ErrorActionPreference = $old_ErrorActionPreference 

$command = "az login --service-principal --username $userName --password $password --tenant $tenantId"
$result = ExecuteCommand $command $loggingPrefix "Logging in the Azure CLI"
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

$command = "az group create -n $resourceGroupName -l $region"
$result = ExecuteCommand $command $loggingPrefix "Creating the resource group."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

$command = "az group deployment create -g $resourceGroupName --template-file $deploymentFile --parameters $deploymentParameters --mode Complete"
$result = ExecuteCommand $command $loggingPrefix "Deploying the infrastructure."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

$command = "az storage container create --account-name $storageAccountName --name $storageContainerName"
$result = ExecuteCommand $command $loggingPrefix "Creating the stoarge container."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

$command = "az storage cors clear --account-name $storageAccountName --services b"
$result = ExecuteCommand $command $loggingPrefix "Clearing the storage account CORS policy."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

$command = "az storage cors add --account-name $storageAccountName --services b --methods POST GET PUT --origins ""*"" --allowed-headers ""*"" --exposed-headers ""*"""
$result = ExecuteCommand $command $loggingPrefix "Creating the storage account CORS policy."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

D "Deployed the microservice infrastructure." $loggingPrefix
Set-Location $currentDirectory