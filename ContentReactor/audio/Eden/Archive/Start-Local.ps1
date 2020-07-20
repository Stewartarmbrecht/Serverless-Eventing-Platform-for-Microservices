[CmdletBinding()]
param(
    [Parameter()]
    [Switch]$Continuous,
    [Parameter()]
    [switch]$RunAutomatedTests,
    [Parameter()]
    [switch]$RunAutomatedTestsContinuously
)

try
{

    $currentDirectory = Get-Location
    Set-Location $PSScriptRoot

    . ./Functions.ps1

    ./Configure-Environment.ps1

    $instanceName = $Env:InstanceName
    $port = $Env:AudioLocalHostingPort

    $loggingPrefix = "ContentReactor Audio Run $instanceName"

    Write-EdenBuildInfo "Starting jobs." $loggingPrefix

    $serviceJob = Start-Function -FunctionLocation "./../Service" -Port $port -LoggingPrefix $loggingPrefix -Continuous:$Continuous

    $localTunnelJob = Start-LocalTunnel -Port $port -LoggingPrefix $loggingPrefix

    $publicUrl = ""
    $healthCheck = $FALSE
    $subscribed = $FALSE
    $testing = $FALSE

    While($serviceJob.State -eq "Running")
    {
        if ([string]::IsNullOrEmpty($publicUrl)) {
            $publicUrl = Get-PublicUrl -Port $port -LoggingPrefix $loggingPrefix
        }
        
        if ($FALSE -eq $healthCheck -and ![string]::IsNullOrEmpty($publicUrl)) {
            $healthCheck = Get-HealthStatus -PublicUrl $publicUrl -LoggingPrefix $loggingPrefix
        }
        
        
        if($subscribed -eq $FALSE -and ![string]::IsNullOrEmpty($publicUrl) -and $TRUE -eq $healthCheck) {
            Write-EdenBuildInfo "Deploying subscriptions to event grid." $loggingPrefix
            Deploy-LocalSubscriptions `
                -PublicUrlToLocalWebServer $publicUrl `
                -LoggingPrefix $loggingPrefix
            $subscribed = $TRUE
        }

        if(
            ($RunAutomatedTestsContinuously -or $RunAutomatedTests) `
            -and $FALSE -eq $testing `
            -and $TRUE -eq $subscribed `
            -and "" -ne $publicUrl `
            -and $TRUE -eq $healthCheck) {
            if ($RunAutomatedTestsContinuously) {
                $automatedTestJob = Test-Automated `
                    -AutomatedUrl "http://localhost:$port/api/audio" `
                    -LoggingPrefix $loggingPrefix `
                    -Continuous
            } else {
                $automatedTestJob = Test-Automated `
                    -AutomatedUrl "http://localhost:$port/api/audio" `
                    -LoggingPrefix $loggingPrefix
            }
            $testing = $TRUE
        }

        Get-Job | Receive-Job | Write-Verbose
        if ($automatedTestJob -and $automatedTestJob.State -ne "Running")
        {
            Write-EdenBuildInfo "Stopping and removing jobs because testing is no longer running." $loggingPrefix
            Stop-Job rt-*
            Remove-Job rt-*
            Write-EdenBuildInfo "Stopped." $loggingPrefix
        }
     }

     Get-Job | Receive-Job | Write-Verbose
     Set-Location $currentDirectory
} 
finally 
{
    Write-EdenBuildInfo "Stopping and removing jobs." $loggingPrefix
    Stop-Job rt-*
    Remove-Job rt-*
    Write-EdenBuildInfo "Stopped." $loggingPrefix
}