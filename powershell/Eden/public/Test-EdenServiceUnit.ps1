function Test-EdenServiceUnit
{
    [CmdletBinding()]
    param(  
        [Alias("c")]
        [switch] $Continuous
    )

    try
    {
        $currentDirectory = Get-Location

        $solutionName = Get-SolutionName
        $serviceName = Get-ServiceName
    
        $loggingPrefix = "$solutionName $serviceName Test Unit"
        
        $verbose = $VerbosePreference
        
        if ($Continuous) {
            Write-BuildInfo "Running the unit tests continuously." $loggingPrefix
            $VerbosePreference = "Continue"
            Invoke-CommandTestUnitContinuous -SolutionName $solutionName -ServiceName $serviceName
        }
        else 
        {
            Write-BuildInfo "Running the unit tests." $loggingPrefix
            Invoke-CommandTestUnit -SolutionName $solutionName -ServiceName $serviceName
        }
        
        $VerbosePreference = $verbose
        Write-BuildInfo "Finished running unit tests." $loggingPrefix

        Set-Location $currentDirectory
    }
    catch
    {
        $VerbosePreference = $verbose
        Set-Location $currentDirectory
        Write-BuildError "Running unit tests failed." $loggingPrefix
        throw $_
    }
}