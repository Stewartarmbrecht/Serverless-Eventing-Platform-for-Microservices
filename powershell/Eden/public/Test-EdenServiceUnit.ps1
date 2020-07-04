function Test-EdenServiceUnit
{
    [CmdletBinding()]
    param(  
        [Alias("c")]
        [switch] $Continuous
    )

    try
    {
        $solutionName = Get-SolutionName
        $serviceName = Get-ServiceName
    
        $edenEnvConfig = Get-EdenEnvConfig -SolutionName $solutionName -ServiceName $serviceName

        $loggingPrefix = "$solutionName $serviceName Test Unit"
        
        $verbose = $VerbosePreference
        
        if ($Continuous) {
            Write-BuildInfo "Running the unit tests continuously." $loggingPrefix
            $VerbosePreference = "Continue"
            Invoke-CommandTestUnitContinuous -EdenEnvConfig $edenEnvConfig
        }
        else 
        {
            Write-BuildInfo "Running the unit tests." $loggingPrefix
            Invoke-CommandTestUnit -EdenEnvConfig $edenEnvConfig
        }
        
        $VerbosePreference = $verbose
        Write-BuildInfo "Finished running the unit tests." $loggingPrefix
    }
    catch
    {
        $VerbosePreference = $verbose
        Write-BuildError "Error unit testing the service. Message: '$($_.Exception.Message)'" $loggingPrefix
        throw $_
    }
}