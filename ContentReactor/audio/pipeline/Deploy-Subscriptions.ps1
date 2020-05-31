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

$loggingPrefix = "ContentReactor Audio Deploy Subscriptions $instanceName"

$eventsResourceGroupName = "$instanceName-events"
$eventsSubscriptionDeploymentFile = "./../infrastructure/subscriptions.json"
$eventsSubscriptionParameters="uniqueResourcesystemName=$instanceName"

Write-BuildInfo "Deploying the microservice subscriptions." $loggingPrefix

$command = "az login --service-principal --username $userName --password $password --tenant $tenantId"
Invoke-BuildCommand $command $loggingPrefix "Logging in the Azure CLI"

$command = "az deployment group create -g $eventsResourceGroupName --template-file $eventsSubscriptionDeploymentFile --parameters $eventsSubscriptionParameters"
Invoke-BuildCommand $command $loggingPrefix "Deploying the event grid subscription."

Write-BuildInfo "Deployed the microservice subscriptions." $loggingPrefix
Set-Location $currentDirectory