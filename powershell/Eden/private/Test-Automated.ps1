function Test-Automated
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [String]$SolutionName,
        [Parameter(Mandatory=$TRUE)]
        [String]$ServiceName,
        [Parameter(Mandatory=$TRUE)]
        [String]$AutomatedUrl,
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix,
        [Parameter()]
        [switch]$Continuous
    )

    try {
        $Env:AutomatedUrl = $AutomatedUrl
        Write-BuildInfo "Running automated tests against '$AutomatedUrl'." $LoggingPrefix
    
        if ($Continuous)
        {
            Write-BuildInfo "Running automated tests continuously." $LoggingPrefix
            Invoke-CommandTestAutomatedContinuous -SolutionName $SolutionName -ServiceName $ServiceName
        }
        else
        {
            Write-BuildInfo "Running automated tests once." $LoggingPrefix
            Invoke-CommandTestAutomated -SolutionName $SolutionName -ServiceName $ServiceName
            Write-BuildInfo "Finished running automated tests." $LoggingPrefix
        }
        }
    catch {
        Write-BuildError "Exception thrown while executing the automated tests. Message: '$($_.Exception.Message)'" $LoggingPrefix
        throw $_        
    }
}