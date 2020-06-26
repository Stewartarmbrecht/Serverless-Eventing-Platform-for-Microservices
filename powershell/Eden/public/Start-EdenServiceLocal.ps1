function Start-EdenServiceLocal
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [Switch]$Continuous,
        [Parameter()]
        [switch]$RunAutomatedTests,
        [Parameter()]
        [switch]$RunAutomatedTestsContinuously
    )
    
    try {
    
        $currentDirectory = Get-Location

        $solutionName = Get-SolutionName
        $serviceName = Get-ServiceName
        
        Set-EdenServiceEnvVariables -Check
    
        $instanceName = Get-EnvironmentVariable "$solutionName.$serviceName.InstanceName"
        $port = Get-EnvironmentVariable "$solutionName.$serviceName.LocalHostingPort"
    
        $loggingPrefix = "$solutionName $serviceName Run $instanceName"
    
        Write-BuildInfo "Starting jobs." $loggingPrefix
    
        Start-ApplicationJob -Location "./Service" -Port $port -LoggingPrefix $loggingPrefix
    
        $serviceUrl = "http://localhost:$port"
        $healthCheck = $FALSE
        $testing = $FALSE
    
        While(Get-Job -State "Running")
        {
            if ($FALSE -eq $healthCheck -and ![string]::IsNullOrEmpty($serviceUrl)) {
                $healthCheck = Get-HealthStatus -PublicUrl $serviceUrl -LoggingPrefix $loggingPrefix
            }
    
            if(
                ($RunAutomatedTestsContinuously -or $RunAutomatedTests) `
                -and $FALSE -eq $testing `
                -and "" -ne $serviceUrl `
                -and $TRUE -eq $healthCheck) {
                if ($RunAutomatedTestsContinuously) {
                    Write-BuildInfo "Starting continuous automated test job." $loggingPrefix
                    $automatedTestJob = Test-AutomatedJob `
                        -SolutionName $solutionName `
                        -ServiceName $serviceName `
                        -AutomatedUrl "http://localhost:$port/api" `
                        -LoggingPrefix $loggingPrefix `
                        -Continuous
                } else {
                    Write-BuildInfo "Starting automated test job." $loggingPrefix
                    $automatedTestJob = Test-AutomatedJob `
                        -SolutionName $solutionName `
                        -ServiceName $serviceName `
                        -AutomatedUrl "http://localhost:$port/api" `
                        -LoggingPrefix $loggingPrefix
                }
                $testing = $TRUE
            }
    
            if ($automatedTestJob -and $automatedTestJob.State -eq "Completed")
            {
                Write-BuildInfo "Stopping and removing jobs." $loggingPrefix
                Stop-Job rt-*
                Remove-Job rt-*
                Write-BuildInfo "Stopped." $loggingPrefix
            }
            Get-Job | Receive-Job | Write-Verbose
        }
    
        Write-BuildInfo "All jobs stopped running." $loggingPrefix

        Get-Job | Receive-Job | Write-Verbose
    
        if (Get-Job -State "Failed") 
        {
            throw "One of the jobs failed."
        }
    
        Set-Location $currentDirectory
    } 
    catch 
    {
        Write-BuildError "Stopping and removing jobs due to exception. Message: '$($_.Exception.Message)'" $loggingPrefix
        Stop-Job rt-*
        Remove-Job rt-*
        Write-BuildError "Stopped." $loggingPrefix
        throw $_
    }
}
