function Show-EdenServiceCodeTestResults {
    [CmdletBinding()]
    param(
        [Alias("p")]
        [Switch] $Published
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Test Code"

        if ($Published) {
            Write-EdenBuildInfo "Launching the published service code test results report." $loggingPrefix

            Invoke-EdenCommand "Show-ServiceCodeTestResultsPublished" $edenEnvConfig $loggingPrefix
        } else {
            Write-EdenBuildInfo "Launching the service code test results report." $loggingPrefix

            Invoke-EdenCommand "Show-ServiceCodeTestResults" $edenEnvConfig $loggingPrefix
        }
    }
    catch {
        Write-EdenBuildError "Error launching the service code test results report. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-tctr `
    -Value Show-EdenServiceCodeTestResults
