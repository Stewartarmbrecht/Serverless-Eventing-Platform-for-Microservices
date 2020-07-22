function Show-EdenServiceTestResults {
    [CmdletBinding()]
    param(  
        [Switch] $Published
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig -Check
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Show Results"

        if ($Published) {
            Write-EdenBuildInfo "Launching the published service test results report." $loggingPrefix

            Invoke-EdenCommand "Show-ServiceTestResultsPublished" $edenEnvConfig $loggingPrefix
        } else {
            Write-EdenBuildInfo "Launching the service test results report." $loggingPrefix

            Invoke-EdenCommand "Show-ServiceTestResults" $edenEnvConfig $loggingPrefix
        }
    }
    catch {
        Write-EdenBuildError "Error launching the service test results report. Message: '$($_.Exception.Message)'" $loggingPrefix
        exit 1
    }    
}
