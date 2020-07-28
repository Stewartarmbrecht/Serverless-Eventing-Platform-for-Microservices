function Show-EdenServiceFeaturesTestResults {
    [CmdletBinding()]
    param(
        [Alias("p")]
        [Switch] $Published
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Show Results"

        if ($Published) {
            Write-EdenBuildInfo "Launching the published service features test results report." $loggingPrefix

            Invoke-EdenCommand "Show-ServiceFeaturesTestResultsPublished" $edenEnvConfig $loggingPrefix
        } else {
            Write-EdenBuildInfo "Launching the service features test results report." $loggingPrefix

            Invoke-EdenCommand "Show-ServiceFeaturesTestResults" $edenEnvConfig $loggingPrefix
        }
    }
    catch {
        Write-EdenBuildError "Error launching the service features test results report. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-tftr `
    -Value Show-EdenServiceFeaturesTestResults
