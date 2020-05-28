[CmdletBinding()]
param()
$currentDirectory = Get-Location
Set-Location $PSScriptRoot

. ./Functions.ps1

./Configure-Environment.ps1

Set-Location "./../"
$location = Get-Location

$instanceName = $Env:InstanceName
$userName = $Env:UserName
$password = $Env:Password
$tenantId = $Env:TenantId
$uniqueDeveloperId = $Env:UniqueDeveloperId
$region = $Env:Region

$loggingPrefix = "ContentReactor Audio Deploy Apps $instanceName"

Write-BuildInfo "Deploying the applications." $loggingPrefix

$resourceGroupName = "$instanceName-audio".ToLower()
$apiName = "$instanceName-audio-api".ToLower()
$apiFilePath = "$location/.dist/api.zip"
$workerName = "$instanceName-audio-worker".ToLower()
$workerFilePath = "$location/.dist/worker.zip"

Set-Location "$PSSCriptRoot"

$command = "az login --service-principal --username $userName --password $password --tenant $tenantId"
Invoke-BuildCommand $command $loggingPrefix "Logging in to the Azure CLI."

$old_ErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

$command = "az webapp deployment source config-zip --resource-group $resourceGroupName --name $apiName --src $apiFilePath"
Invoke-BuildCommand $command $loggingPrefix "Deploying the API application."

$command = "az webapp deployment source config-zip --resource-group $resourceGroupName --name $workerName --src $workerFilePath"
Invoke-BuildCommand $command $loggingPrefix "Deploying the worker application."

$ErrorActionPreference = $old_ErrorActionPreference 
Write-BuildInfo "Finished deploying the applications." $loggingPrefix
Set-Location $currentDirectory