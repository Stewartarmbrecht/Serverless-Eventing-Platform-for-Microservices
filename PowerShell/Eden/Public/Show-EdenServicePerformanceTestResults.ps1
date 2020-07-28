function Show-EdenServicePerformanceTestResults {
    [CmdletBinding()]
    param(
        [Alias("p")]
        [Switch] $Published
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Show Results"

        if ($Published) {
            Write-EdenBuildInfo "Launching the published service performance test results report." $loggingPrefix

            Invoke-EdenCommand "Show-ServicePerformanceTestResultsPublished" $edenEnvConfig $loggingPrefix
        } else {
            Write-EdenBuildInfo "Launching the service performance test results report." $loggingPrefix

            Invoke-EdenCommand "Show-ServicePerformanceTestResults" $edenEnvConfig $loggingPrefix
        }
    }
    catch {
        Write-EdenBuildError "Error launching the service performance test results report. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-tptr `
    -Value Show-EdenServicePerformanceTestResults
