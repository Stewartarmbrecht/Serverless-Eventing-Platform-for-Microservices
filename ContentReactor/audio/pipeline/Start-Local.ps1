[CmdletBinding()]
param(
    [Parameter()]
    [Switch]$Continuous,
    [Parameter()]
    [switch]$RunAutomatedTests,
    [Parameter()]
    [switch]$RunAutomatedTestsContinuously
)

$currentDirectory = Get-Location
Set-Location $PSScriptRoot

. ./Functions.ps1

. ./Configure-Environment.ps1

$instanceName = $Env:InstanceName
$port = $Env:AudioLocalHostingPort

$loggingPrefix = "ContentReactor Audio Run $instanceName"

Write-BuildInfo "Starting jobs." $loggingPrefix

Start-Function -FunctionLocation "./../application" -Port $port -LoggingPrefix $loggingPrefix -Continuous:$Continuous

Start-LocalTunnel -Port $port -LoggingPrefix $loggingPrefix

$publicUrl = ""
$healthCheck = $FALSE
$subscribed = $FALSE
$testing = $FALSE

# Change the default behavior of CTRL-C so that the script can intercept and use it versus just terminating the script.
[Console]::TreatControlCAsInput = $True

While(Get-Job -State "Running")
{
    if ([string]::IsNullOrEmpty($publicUrl)) {
        $publicUrl = Get-PublicUrl -Port $port -LoggingPrefix $loggingPrefix
    }
    
    if ($FALSE -eq $healthCheck -and ![string]::IsNullOrEmpty($publicUrl)) {
        $healthCheck = Get-HealthStatus -PublicUrl $publicUrl -LoggingPrefix $loggingPrefix
    }
    
    
    if($subscribed -eq $FALSE -and ![string]::IsNullOrEmpty($publicUrl) -and $TRUE -eq $healthCheck) {
        Write-BuildInfo "Deploying subscriptions to event grid." $loggingPrefix
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
    if ($automatedTestJob.State -eq "Completed")
    {
        Write-BuildInfo "Stopping and removing jobs." $loggingPrefix
        Stop-Job rt-*
        Remove-Job rt-*
        Write-BuildInfo "Stopped." $loggingPrefix
    }
    # Sleep for 1 second and then flush the key buffer so any previously pressed keys are discarded and the loop can monitor for the use of
    #   CTRL-C. The sleep command ensures the buffer flushes correctly.
    # $Host.UI.RawUI.FlushInputBuffer()
    Start-Sleep -Seconds 1
    # If a key was pressed during the loop execution, check to see if it was CTRL-C (aka "3"), and if so exit the script after clearing
    #   out any running jobs and setting CTRL-C back to normal.
    If ($Host.UI.RawUI.KeyAvailable -and ($Key = $Host.UI.RawUI.ReadKey("AllowCtrlC,NoEcho,IncludeKeyUp"))) {
        If ([Int]$Key.Character -eq 3) {
            Write-Warning "CTRL-C was used - Shutting down any running jobs before exiting the script."
            Write-BuildInfo "Stopping and removing jobs." $loggingPrefix
            Stop-Job rt-*
            Remove-Job rt-*
            Write-BuildInfo "Stopped." $loggingPrefix
            [Console]::TreatControlCAsInput = $False
        }
        # Flush the key buffer again for the next loop.
        # $Host.UI.RawUI.FlushInputBuffer()
    }
}

Set-Location $currentDirectory
