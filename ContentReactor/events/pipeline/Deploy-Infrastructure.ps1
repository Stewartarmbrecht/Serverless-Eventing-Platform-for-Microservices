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

$loggingPrefix = "ContentReactor Events Deployment $instanceName "
$resourceGroupName = "$instanceName-events"
$deploymentFile = "./../infrastructure/eventGridTemplate.json"
$deploymentParameters = "instanceName=$instanceName"

. ./Functions.ps1

Write-BuildInfo "Deploying the event grid." $loggingPrefix

$command = "az login --service-principal --username $userName --password $password --tenant $tenantId"
Invoke-BuildCommand $command $loggingPrefix "Logging in the Azure CLI"

$command = "az group create -n $resourceGroupName -l $region"
Invoke-BuildCommand $command $loggingPrefix "Creating the resource group."

$command = "az group deployment create -g $resourceGroupName --template-file $deploymentFile --parameters $deploymentParameters --mode Complete"
Invoke-BuildCommand $command $loggingPrefix "Deploying the infrastructure."

Write-BuildInfo "Deployed the event grid infrastructure." $loggingPrefix
Set-Location $currentDirectory