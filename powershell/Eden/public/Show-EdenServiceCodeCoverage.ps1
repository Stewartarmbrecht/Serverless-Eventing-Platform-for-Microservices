function Show-EdenServiceCodeCoverage {
    [CmdletBinding()]
    param(
        [Switch] $Published
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig -Check
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Show Coverage"

        if ($Published) {
            Write-EdenBuildInfo "Launching the published service code coverage report." $loggingPrefix

            Invoke-EdenCommand "Show-ServiceCodeCoveragePublished" $edenEnvConfig $loggingPrefix    
        } else {
            Write-EdenBuildInfo "Launching the service code coverage report." $loggingPrefix

            Invoke-EdenCommand "Show-ServiceCodeCoverage" $edenEnvConfig $loggingPrefix                
        }
    }
    catch {
        Write-EdenBuildError "Error launching the service code coverage report. Message: '$($_.Exception.Message)'" $loggingPrefix
        exit 1
    }    
}
