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

$loggingPrefix = "ContentReactor Api Deploy App $instanceName"

Write-EdenBuildInfo "Deploying the api function application." $loggingPrefix

$resourceGroupName = "$instanceName-api".ToLower()
$apiName = "$instanceName-api".ToLower()
$apiFilePath = "$location/.dist/app.zip"

Set-Location "$PSSCriptRoot"

Connect-AzureServicePrincipal $loggingPrefix

Write-EdenBuildInfo "Deploying the azure functions app using zip from '$apiFilePath' to group '$resourceGroupName', app '$apiName' on the staging slot." $loggingPrefix
$result = Publish-AzWebApp -ResourceGroupName $resourceGroupName -Name $apiName -Slot Staging -ArchivePath $apiFilePath -Force
if ($VerbosePreference -ne 'SilentlyContinue') { $result }

$automatedTestJob = Test-Automated -AutomatedUrl "https://$apiName-staging.azurewebsites.net/api/audio" -LoggingPrefix $loggingPrefix
While($automatedTestJob.State -eq "Running")
{
    $automatedTestJob | Receive-Job | Write-Verbose
}
$automatedTestJob | Receive-Job | Write-Verbose
if ($automatedTestJob.State -eq "Failed") {
    Write-EdenBuildError "The staging end to end testing failed." $loggingPrefix
    Write-EdenBuildError "Exiting deployment." $loggingPrefix
    Get-Job | Remove-Job
    Exit
}
Get-Job | Remove-Job

Write-EdenBuildInfo "Switching the '$resourceGroupName/$apiName' azure functions app staging slot with production." $loggingPrefix
$result = Switch-AzWebAppSlot -SourceSlotName "Staging" -DestinationSlotName "Production" -ResourceGroupName $resourceGroupName -Name $apiName
if ($VerbosePreference -ne 'SilentlyContinue') { $result }

Write-EdenBuildInfo "Finished deploying the application." $loggingPrefix
Set-Location $currentDirectory