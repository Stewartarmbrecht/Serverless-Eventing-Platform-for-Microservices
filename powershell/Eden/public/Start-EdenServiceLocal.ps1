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

        Write-BuildInfo "Starting the local service." $loggingPrefix

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

        # Write-Verbose "Before: Service Job: $($serviceJob.State)"
        # Write-Verbose "Before: Tunnel Job: $($tunnelJob.State)"
        # Write-Verbose "Before: Testing Job: $($testingJob.State)"

        While (!$serviceJob -or $serviceJob.State -eq "NotStarted" -or !$tunnelJob -or $tunnelJob.State -eq "NotStarted") {}

        While(`
            ($serviceJob.State -eq "Running" -or $serviceJob.State -eq "NotStarted") `
            -and ($tunnelJob.State -eq "Running" -or $tunnelJob.State -eq "NotStarted") `
            -and ($null -eq $testingJob -or $testingJob.State -eq "Running" -or $testingJob.State -eq "NotStarted"))
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
            if (($RunFeatureTests -or $RunFeatureTestsContinuously) -and $subscriptionsDeployed -and $null -eq $testingJob) {
                if ($RunFeatureTestsContinuously) {
                    Write-BuildInfo "Testing the service features continuously." $loggingPrefix
                    $testingJob = Start-EdenCommand  `
                        -EdenCommand "Test-FeaturesContinuously" `
                        -EdenEnvConfig $edenEnvConfig `
                        -LoggingPrefix $loggingPrefix
                } else { 
                    Write-BuildInfo "Testing the service features." $loggingPrefix
                    Invoke-EdenCommand "Test-Features" $edenEnvConfig $loggingPrefix
                    Write-BuildInfo "Finished testing the service features." $loggingPrefix
                    Write-BuildInfo "Stopping and removing jobs." $loggingPrefix
                    $serviceJob.StopJob()
                    # Remove-Job -Id $serviceJob.Id -Force
                    $tunnelJob.StopJob()
                    # Remove-Job -Id $tunnelJob.Id -Force
                }
            }

            $serviceJob | Receive-Job | Write-Verbose
            $tunnelJob | Receive-Job | Write-Verbose
            if ($testingJob) {
                $testingJob | Receive-Job | Write-Verbose
            }
            Write-Verbose "Sleeping."
            Start-Sleep 1
            # Write-Verbose "Inside: Service Job: $($serviceJob.State)"
            # Write-Verbose "Inside: Tunnel Job: $($tunnelJob.State)"
            # Write-Verbose "Inside: Testing Job: $($testingJob)"
        }

        # Write-Verbose "After: Service Job: $($serviceJob.State)"
        # Write-Verbose "After: Tunnel Job: $($tunnelJob.State)"
        # Write-Verbose "After: Testing Job: $($testingJob.State)"

        $serviceJob | Receive-Job | Write-Verbose
        $tunnelJob | Receive-Job | Write-Verbose
        if ($testingJob) {
            $testingJob | Receive-Job | Write-Verbose
        }

        if ($serviceJob.State -eq "Failed") 
        {
            #TODO: Figure out how to ensure StatusMessage has the message from a thrown error in the job.
            throw "Local service failed to run. Status Message: '$($serviceJob.JobStateInfo.Reason.Message)'"
        }
    
        if ($tunnelJob.State -eq "Failed") 
        {
            #TODO: Figure out how to ensure StatusMessage has the message from a thrown error in the job.
            throw "Local tunnel failed to run. Status Message: '$($tunnelJob.JobStateInfo.Reason.Message)'"
        }
    
        if ($testingJob.State -eq "Failed") 
        {
            #TODO: Figure out how to ensure StatusMessage has the message from a thrown error in the job.
            throw "Continuous feature testing failed to run. Status Message: '$($testingJob.JobStateInfo.Reason.Message)'"
        }
    
        Write-BuildInfo "Stopping the local service." $loggingPrefix

        if ($serviceJob) {
            $serviceJob.StopJob()
            Remove-Job -Id $serviceJob.Id
        }
        if ($tunnelJob.State) {
            $tunnelJob.StopJob()
            Remove-Job -Id $tunnelJob.Id -Force
        }
        if ($testingJob) {
            $testingJob.StopJob()
            Remove-Job -Id $testingJob.Id -Force
        }

        Write-BuildInfo "Finished stopping the local service." $loggingPrefix
    } 
    catch 
    {
        Write-BuildError "Stopping and removing jobs due to exception. Message: '$($_.Exception.Message)'" $loggingPrefix
        $serviceJob.StopJob()
        $serviceJob | Remove-Job -Force
        $tunnelJob.StopJob()
        $tunnelJob | Remove-Job -Force
        if ($testingJob) {
            $testingJob.StopJob()
            $testingJob | Remove-Job -Force
        }
        Write-BuildError "Stopped." $loggingPrefix
        throw $_
    }
}
