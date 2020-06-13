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

$loggingPrefix = "ContentReactor Api Deploy Infrastructure $instanceName "
$resourceGroupName = "$instanceName-api"
$deploymentFile = "./../infrastructure/infrastructure.json"
#$deploymentParameters = "instanceName=$instanceName"

. ./Functions.ps1

Write-BuildInfo "Deploying the api." $loggingPrefix

Connect-AzureServicePrincipal $loggingPrefix

$result = New-AzResourceGroup -Name $resourceGroupName -Location $region -Force
if ($VerbosePreference -ne 'SilentlyContinue') { $result }

$result = New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $deploymentFile -InstanceName $instanceName
if ($VerbosePreference -ne 'SilentlyContinue') { $result }

Write-BuildInfo "Deployed the api infrastructure." $loggingPrefix
Set-Location $currentDirectory