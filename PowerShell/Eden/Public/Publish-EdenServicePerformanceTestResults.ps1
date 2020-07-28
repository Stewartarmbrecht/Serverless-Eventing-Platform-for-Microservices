function Publish-EdenServicePerformanceTestResults {
    [CmdletBinding()]
    param(  
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig -Check
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Publish Results"

        Write-EdenBuildInfo "Publishing the service performance test results." $loggingPrefix

        Invoke-EdenCommand "Publish-ServicePerformanceTestResults" $edenEnvConfig $loggingPrefix
        
        Write-EdenBuildInfo "Finished publishing the service performance test results." $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error publishing the service performance test results. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-tptrp `
    -Value Publish-EdenServicePerformanceTestResults
