[CmdletBinding()]
param()
$currentDirectory = Get-Location
Set-Location $PSScriptRoot

. ./Functions.ps1

./Configure-Environment.ps1

$instanceName = $Env:InstanceName
$region = $Env:Region

$loggingPrefix = "ContentReactor Audio Deploy Subscriptions $instanceName"

$eventsResourceGroupName = "$instanceName-events"
$eventsSubscriptionDeploymentFile = "./../Infrastructure/Subscriptions.json"

Write-EdenBuildInfo "Deploying the microservice subscriptions." $loggingPrefix

Connect-AzureServicePrincipal $loggingPrefix

Write-EdenBuildInfo "Deploying the event grid subscriptions for the functions app." $loggingPrefix
Write-EdenBuildInfo "Deploying to '$eventsResourceGroupName' events resource group." $loggingPrefix
$result = New-AzResourceGroupDeployment -ResourceGroupName $eventsResourceGroupName -TemplateFile $eventsSubscriptionDeploymentFile -InstanceName $instanceName
if ($VerbosePreference -ne 'SilentlyContinue') { $result }

Write-EdenBuildInfo "Deployed the microservice subscriptions." $loggingPrefix
Set-Location $currentDirectory