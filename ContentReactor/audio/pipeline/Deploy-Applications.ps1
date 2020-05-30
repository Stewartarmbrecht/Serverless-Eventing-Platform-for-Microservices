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

# $old_ErrorActionPreference = $ErrorActionPreference
# $ErrorActionPreference = 'SilentlyContinue'

$command = "az webapp deployment source config-zip --resource-group $resourceGroupName --name $apiName --src $apiFilePath --slot staging"
Invoke-BuildCommand $command $loggingPrefix "Deploying the API application."

$command = "az webapp deployment source config-zip --resource-group $resourceGroupName --name $workerName --src $workerFilePath --slot staging"
Invoke-BuildCommand $command $loggingPrefix "Deploying the worker application."

$e2eTestJob = Test-EndToEnd -E2EUrl "https://$apiName-staging.azurewebsites.net/api/audio" -LoggingPrefix $loggingPrefix
While($e2eTestJob.State -eq "Running")
{
    $e2eTestJob | Receive-Job | Write-Verbose
}
$e2eTestJob | Receive-Job | Write-Verbose
if ($e2eTestJob.State -eq "Failed") {
    Write-BuildError "The staging end to end testing failed." $loggingPrefix
    Write-BuildError "Exiting deployment." $loggingPrefix
    Get-Job | Remove-Job
    Exit
}
Get-Job | Remove-Job

$command = "az functionapp deployment slot swap -g $resourceGroupName -n $apiName --slot staging --target-slot production"
Invoke-BuildCommand $command $loggingPrefix "Swapping the api staging slot with production."

$command = "az functionapp deployment slot swap -g $resourceGroupName -n $workerName --slot staging --target-slot production"
Invoke-BuildCommand $command $loggingPrefix "Swapping the worker staging slot with production."


# $ErrorActionPreference = $old_ErrorActionPreference 
Write-BuildInfo "Finished deploying the applications." $loggingPrefix
Set-Location $currentDirectory