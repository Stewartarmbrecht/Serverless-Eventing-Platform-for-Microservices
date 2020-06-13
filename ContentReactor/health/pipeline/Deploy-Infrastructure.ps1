[CmdletBinding()]
param()
$currentDirectory = Get-Location
Set-Location $PSScriptRoot

. ./Functions.ps1

./Configure-Environment.ps1

$instanceName = $Env:InstanceName
$region = $Env:Region

$loggingPrefix = "ContentReactor Audio Deploy Infrastructure $instanceName"

$resourceGroupName = "$instanceName-audio".ToLower()
$deploymentFile = "./../infrastructure/infrastructure.json"

Write-BuildInfo "Deploying the service infrastructure." $loggingPrefix

Connect-AzureServicePrincipal $loggingPrefix

Write-BuildInfo "Creating the resource group: $resourceGroupName." $loggingPrefix
New-AzResourceGroup -Name $resourceGroupName -Location $region -Force | Write-Verbose

Write-BuildInfo "Executing the deployment using: $deploymentFile." $loggingPrefix
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $deploymentFile -InstanceName $instanceName | Write-Verbose

Write-BuildInfo "Deployed the service infrastructure." $loggingPrefix
Set-Location $currentDirectory