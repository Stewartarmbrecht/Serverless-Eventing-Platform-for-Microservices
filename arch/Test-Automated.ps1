function Test-Automated
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [EdenEnvConfig] $EdenEnvConfig,
        [Parameter()]
        [switch] $Continuous
    )

    try {

        $loggingPrefix = "$($EdenEnvConfig.SolutionName) $($EdenEnvConfig.ServiceName) Test Automated"

        Write-EdenBuildInfo "Running automated tests against the local environment." $loggingPrefix
    
        if ($Continuous)
        {
            Write-EdenBuildInfo "Running automated tests continuously." $loggingPrefix
            Invoke-CommandTestAutomatedContinuous -EdenEnvConfig $EdenEnvConfig
        }
        else
        {
            Write-EdenBuildInfo "Running automated tests once." $loggingPrefix
            Invoke-CommandTestAutomated -EdenEnvConfig $EdenEnvConfig
            Write-EdenBuildInfo "Finished running automated tests." $loggingPrefix
        }
    }
    catch {
        Write-EdenBuildError "Exception thrown while executing the automated tests. Message: '$($_.Exception.Message)'" $loggingPrefix
        throw $_        
    }
}