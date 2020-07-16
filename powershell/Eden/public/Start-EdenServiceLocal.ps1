function Start-EdenServiceLocal
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [Switch]$Continuous,
        [Parameter()]
        [switch]$RunFeatureTests,
        [Parameter()]
        [switch]$RunFeatureTestsContinuously
    )
    
    try {
    
        $edenEnvConfig = Get-EdenEnvConfig -Check
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Run $($edenEnvConfig.EnvironmentName)"

        if ($Continuous) {
            $startCommand = "Start-LocalServiceContinuous"
        } else {
            $startCommand = "Start-LocalService"
        }
        
        Write-BuildInfo "Starting the local service job." $loggingPrefix
        $serviceJob = Start-EdenCommand `
            -EdenCommand $startCommand `
            -EdenEnvConfig $edenEnvConfig `
            -LoggingPrefix $loggingPrefix

        Write-BuildInfo "Starting the public tunnel job." $loggingPrefix
        $tunnelJob = Start-EdenCommand `
            -EdenCommand "Start-LocalTunnel" `
            -EdenEnvConfig $edenEnvConfig `
            -LoggingPrefix $loggingPrefix

        $serviceReady = $false
        $subscriptionsDeployed = $false

        While(($serviceJob.State -eq "Running" -or $serviceJob.State -eq "NotStarted") `
            -and ($tunnelJob.State -eq "Running" -or $tunnelJob.State -eq "NotStarted"))
        {
            if (!$serviceReady) {
                Write-BuildInfo "Checking whether the local service is ready." $loggingPrefix
                $serviceReady = Invoke-EdenCommand "Get-LocalServiceHealth" $edenEnvConfig $loggingPrefix
                if ($serviceReady) {
                    Write-BuildInfo "The local service passed the health check." $loggingPrefix    
                } else {
                    Write-BuildError "The local service failed the health check." $loggingPrefix    
                }
            } 
            if ($serviceReady -and !$subscriptionsDeployed) {
                Write-BuildInfo "Deploying the event subscrpitions for the local service." $loggingPrefix
                Invoke-EdenCommand "Deploy-LocalSubscriptions" $edenEnvConfig $loggingPrefix
                Write-BuildInfo "Finished deploying the event subscrpitions for the local service." $loggingPrefix
                $subscriptionsDeployed = $true
            }
            if ($RunFeatureTests -and $subscriptionsDeployed) {
                if ($RunFeatureTestsContinuously) {
                    Write-BuildInfo "Testing the service features continuously." $loggingPrefix
                    Start-EdenCommand  `
                        -EdenCommand "Test-FeaturesContinuously" `
                        -EdenEnvConfig $edenEnvConfig `
                        -LoggingPrefix $loggingPrefix
                } else { 
                    Write-BuildInfo "Testing the service features." $loggingPrefix
                    Invoke-EdenCommand "Test-Features" $edenEnvConfig $loggingPrefix
                    Write-BuildInfo "Finished testing the service features." $loggingPrefix
                    Write-BuildInfo "Stopping and removing jobs." $loggingPrefix
                    $serviceJob.StopJob()
                    $serviceJob | Remove-Job
                    $tunnelJob.StopJob()
                    $tunnelJob | Remove-Job            
                }
            }

            $serviceJob | Receive-Job | Write-Verbose
            $tunnelJob | Receive-Job | Write-Verbose

            Start-Sleep 1
        }
    
        $serviceJob | Receive-Job | Write-Verbose
        $tunnelJob | Receive-Job | Write-Verbose

        if ($serviceJob.State -eq "Failed") 
        {
            #TODO: Figure out how to ensure StatusMessage has the message from a thrown error in the job.
            throw "Local service failed to run. Status Message: '$($serviceJob.StatusMessage)'"
        }
    
        if ($tunnelJob.State -eq "Failed") 
        {
            #TODO: Figure out how to ensure StatusMessage has the message from a thrown error in the job.
            throw "Local tunnel failed to run. Status Message: '$($tunnelJob.StatusMessage)'"
        }
    
    } 
    catch 
    {
        Write-BuildError "Stopping and removing jobs due to exception. Message: '$($_.Exception.Message)'" $loggingPrefix
        $serviceJob.StopJob()
        $serviceJob | Remove-Job
        $tunnelJob.StopJob()
        $tunnelJob | Remove-Job
        Write-BuildError "Stopped." $loggingPrefix
        throw $_
    }
}
