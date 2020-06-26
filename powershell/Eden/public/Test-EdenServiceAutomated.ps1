function Test-EdenServiceAutomated
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Continuous
    )
    
    try
    {
        $solutionName = Get-SolutionName
        $serviceName = Get-ServiceName
    
        Set-EdenServiceEnvVariables -Check
    
        $instanceName = Get-EnvironmentVariable "$solutionName.$serviceName.InstanceName"
    
        $loggingPrefix = "$solutionName $serviceName Test Automated $instanceName"
    
        if ($Continuous) {
            Write-BuildInfo "Running automated tests continuously." $loggingPrefix
            Start-EdenServiceLocal -RunAutomatedTestsContinuously -Verbose
        } else {
            Write-BuildInfo "Running automated tests." $loggingPrefix
            Start-EdenServiceLocal -RunAutomatedTests
            Write-BuildInfo "Finished running automated tests." $loggingPrefix
        }
    }
    catch
    {
        Write-BuildError "Error running automated tests.  Message: '$($_.Exception.Message)'" $loggingPrefix
        throw $_
    }    
}
