function Show-EdenServiceCodeCoverage {
    [CmdletBinding()]
    param(
        [Alias("p")]
        [Switch] $Published
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Test Code"

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
    }    
}
New-Alias `
    -Name e-tccc `
    -Value Show-EdenServiceCodeCoverage
