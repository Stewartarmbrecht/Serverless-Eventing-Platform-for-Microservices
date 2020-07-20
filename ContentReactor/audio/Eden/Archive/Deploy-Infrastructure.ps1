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
$deploymentFile = "./../Infrastructure/Infrastructure.json"

Write-EdenBuildInfo "Deploying the service infrastructure." $loggingPrefix

Connect-AzureServicePrincipal $loggingPrefix

Write-EdenBuildInfo "Creating the resource group: $resourceGroupName." $loggingPrefix
New-AzResourceGroup -Name $resourceGroupName -Location $region -Force | Write-Verbose

Write-EdenBuildInfo "Executing the deployment using: $deploymentFile." $loggingPrefix
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $deploymentFile -InstanceName $instanceName | Write-Verbose

Write-EdenBuildInfo "Deployed the service infrastructure." $loggingPrefix
Set-Location $currentDirectory