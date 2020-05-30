[CmdletBinding()]
param()
$currentDirectory = Get-Location
Set-Location $PSScriptRoot

. ./Functions.ps1

./Configure-Environment.ps1

$instanceName = $Env:InstanceName
$userName = $Env:UserName
$password = $Env:Password
$tenantId = $Env:TenantId
$uniqueDeveloperId = $Env:UniqueDeveloperId
$region = $Env:Region

$loggingPrefix = "ContentReactor Audio Deploy Infrastructure $instanceName"

$resourceGroupName = "$instanceName-audio".ToLower()
$deploymentFile = "./../infrastructure/microservice.json"

Write-BuildInfo "Deploying the microservice infrastructure." $loggingPrefix

$command = "az login --service-principal --username $userName --password $password --tenant $tenantId"
Invoke-BuildCommand $command $loggingPrefix "Logging in the Azure CLI"

$command = "az group create -n $resourceGroupName -l $region"
Invoke-BuildCommand $command $loggingPrefix "Creating the resource group."

$command = "az deployment group create -g $resourceGroupName --template-file $deploymentFile --parameters instanceName=$instanceName --mode Complete"
Invoke-BuildCommand $command $loggingPrefix "Deploying the infrastructure."

$storageAccountName = "$($instanceName)audioblob".ToLower()
$storageContainerName = "audio"

$command = "az storage container create --account-name $storageAccountName --name $storageContainerName"
Invoke-BuildCommand $command $loggingPrefix "Creating the stoarge container."

$command = "az storage cors clear --account-name $storageAccountName --services b"
Invoke-BuildCommand $command $loggingPrefix "Clearing the storage account CORS policy."

$command = "az storage cors add --account-name $storageAccountName --services b --methods POST GET PUT --origins ""*"" --allowed-headers ""*"" --exposed-headers ""*"""
Invoke-BuildCommand $command $loggingPrefix "Creating the storage account CORS policy."

Write-BuildInfo "Deployed the service infrastructure." $loggingPrefix
Set-Location $currentDirectory