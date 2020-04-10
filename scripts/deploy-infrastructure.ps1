param(  
    [Alias("v")]
    [String] $verbosity
)
$currentDirectory = Get-Location

Set-Location "$PSScriptRoot/../"

. ./scripts/functions.ps1

./scripts/configure-env.ps1

$location = Get-Location

$systemName = $Env:systemName
$microserviceName = $Env:microserviceName
$userName = $Env:userName
$password = $Env:password
$tenantId = $Env:tenantId
$region = $Env:region
$deploymentParameters = $Env:deploymentParameters

$loggingPrefix = "$systemName $microserviceName Deploy Infrastructure"

$resourceGroupName = "$systemName-$microserviceName".ToLower()
$deploymentFile = "$location/$microserviceName/templates/microservice.json"

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

D "Executing post deployment actions." $loggingPrefix

Set-Location "$location/$microserviceName/"
./eden-post-deploy.ps1

D "Finished executing post deployment actions." $loggingPrefix

D "Deployed the microservice infrastructure." $loggingPrefix
Set-Location $currentDirectory