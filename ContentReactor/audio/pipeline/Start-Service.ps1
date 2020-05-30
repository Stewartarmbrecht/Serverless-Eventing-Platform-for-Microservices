[CmdletBinding()]
param(
    [Parameter()]
    [switch]$RunEndToEndTests,
    [Parameter()]
    [switch]$RunEndToEndTestsContinuously
)

$currentDirectory = Get-Location
Set-Location $PSScriptRoot

. ./Functions.ps1

. ./Configure-Environment.ps1

$instanceName = $Env:InstanceName
$userName = $Env:UserName
$password = $Env:Password
$tenantId = $Env:TenantId
$uniqueDeveloperId = $Env:UniqueDeveloperId
$apiPort = $Env:AudioApiPort
$workerPort = $Env:AudioWorkerPort

$loggingPrefix = "ContentReactor Audio Run $instanceName"

Write-BuildInfo "Starting jobs." $loggingPrefix

Start-Function -FunctionType "Api" -FunctionLocation "./../api" -Port $apiPort -LoggingPrefix $loggingPrefix

Start-Function -FunctionType "Worker" -FunctionLocation "./../worker" -Port $workerPort -LoggingPrefix $loggingPrefix

Start-LocalTunnel -FunctionType "Worker" -Port $workerPort -LoggingPrefix $loggingPrefix

$publicUrl = ""
$healthCheck = $FALSE
$subscribed = $FALSE
$testing = $FALSE

# Change the default behavior of CTRL-C so that the script can intercept and use it versus just terminating the script.
[Console]::TreatControlCAsInput = $True

While(Get-Job -State "Running")
{
    if ([string]::IsNullOrEmpty($publicUrl)) {
        $publicUrl = Get-PublicUrl -Port $workerPort -LoggingPrefix $loggingPrefix
    }
    
    if ($FALSE -eq $healthCheck -and ![string]::IsNullOrEmpty($publicUrl)) {
        $healthCheck = Get-HealthStatus -PublicUrl $publicUrl -LoggingPrefix $loggingPrefix
    }
    
    
    if($subscribed -eq $FALSE -and ![string]::IsNullOrEmpty($publicUrl) -and $TRUE -eq $healthCheck) {
        Write-BuildInfo "Deploying subscriptions to event grid." $loggingPrefix
        Deploy-LocalSubscriptions `
            -InstanceName $instanceName `
            -PublicUrlToLocalWebServer $publicUrl `
            -UserName $userName `
            -Password $password `
            -TenantId $tenantId `
            -UniqueDeveloperId $uniqueDeveloperId `
            -LoggingPrefix $loggingPrefix
        $subscribed = $TRUE
    }

    if(
        ($RunEndToEndTestsContinuously -or $RunEndToEndTests) `
        -and $FALSE -eq $testing `
        -and $TRUE -eq $subscribed `
        -and "" -ne $publicUrl `
        -and $TRUE -eq $healthCheck) {
        if ($RunEndToEndTestsContinuously) {
            $e2eTestJob = Test-EndToEnd -E2EUrl "http://localhost:$apiPort/api/audio" -LoggingPrefix $loggingPrefix -Continuous
        } else {
            $e2eTestJob = Test-EndToEnd -E2EUrl "http://localhost:$apiPort/api/audio" -LoggingPrefix $loggingPrefix
        }
        $testing = $TRUE
    }

    Get-Job | Receive-Job | Write-Verbose
    if ($e2eTestJob.State -eq "Completed")
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
