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
#$deploymentParameters = "instanceName=$instanceName"

. ./Functions.ps1

Write-BuildInfo "Deploying the event grid." $loggingPrefix

Connect-AzureServicePrincipal $loggingPrefix

New-AzResourceGroup -Name $resourceGroupName -Location $region -Force

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $deploymentFile -InstanceName $instanceName

Write-BuildInfo "Deployed the event grid infrastructure." $loggingPrefix
Set-Location $currentDirectory