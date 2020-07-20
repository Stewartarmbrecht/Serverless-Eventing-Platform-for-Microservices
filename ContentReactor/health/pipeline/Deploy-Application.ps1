[CmdletBinding()]
param()

$solutionName = "ContentReactor"
$serviceName = "Health"

try {
    $currentDirectory = Get-Location
    Set-Location $PSScriptRoot

    . ./Functions.ps1

    ./Configure-Environment.ps1 -Check

    Set-Location "./../"
    $location = Get-Location

    $instanceName = $Env:InstanceName
    $userName = $Env:UserName
    $password = $Env:Password
    $tenantId = $Env:TenantId
    $uniqueDeveloperId = $Env:UniqueDeveloperId
    $region = $Env:Region

    $loggingPrefix = "$solutionName $serviceName Deploy Apps $instanceName"

    Write-EdenBuildInfo "Deploying the applications." $loggingPrefix

    $resourceGroupName = "$instanceName-$serviceName".ToLower()
    $apiName = "$instanceName-$serviceName".ToLower()
    $apiFilePath = "$location/.dist/app.zip"

    Set-Location "$PSSCriptRoot"

    Connect-AzureServicePrincipal $loggingPrefix

    Write-EdenBuildInfo "Deploying the azure functions app using zip from '$apiFilePath' to group '$resourceGroupName', app '$apiName' on the staging slot." $loggingPrefix
    $result = Publish-AzWebApp -ResourceGroupName $resourceGroupName -Name $apiName -Slot Staging -ArchivePath $apiFilePath -Force
    if ($VerbosePreference -ne 'SilentlyContinue') { $result }

    $automatedTestJob = Test-Automated `
        -SolutionName $solutionName `
        -ServiceName $serviceName `
        -AutomatedUrl "https://$apiName-staging.azurewebsites.net/api/" `
        -LoggingPrefix $loggingPrefix
    While($automatedTestJob.State -eq "Running")
    {
        $automatedTestJob | Receive-Job | Write-Verbose
    }
    $automatedTestJob | Receive-Job | Write-Verbose
    if ($automatedTestJob.State -eq "Failed") {
        Write-EdenBuildError "The staging end to end testing failed." $loggingPrefix
        Write-EdenBuildError "Exiting deployment." $loggingPrefix
        Get-Job | Remove-Job
        throw "Automated tests failed."
    }
    Get-Job | Remove-Job

    Write-EdenBuildInfo "Switching the '$resourceGroupName/$apiName' azure functions app staging slot with production." $loggingPrefix
    $result = Switch-AzWebAppSlot -SourceSlotName "Staging" -DestinationSlotName "Production" -ResourceGroupName $resourceGroupName -Name $apiName
    if ($VerbosePreference -ne 'SilentlyContinue') { $result }

    Write-EdenBuildInfo "Finished deploying the applications." $loggingPrefix
    Set-Location $currentDirectory
}
catch {
    Get-Job | Stop-Job | Remove-Job
    Set-Location $currentDirectory
    throw $_    
}
