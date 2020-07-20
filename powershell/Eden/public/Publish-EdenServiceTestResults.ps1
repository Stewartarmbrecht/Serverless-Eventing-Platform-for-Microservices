function Publish-EdenServiceTestResults {
    [CmdletBinding()]
    param(  
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig -Check
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Publish Results"

        Write-EdenBuildInfo "Publishing the service test results." $loggingPrefix

        Invoke-EdenCommand "Publish-ServiceTestResults" $edenEnvConfig $loggingPrefix
        
        Write-EdenBuildInfo "Finished publishing the service test results." $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error publishing the service test results. Message: '$($_.Exception.Message)'" $loggingPrefix
        exit 1
    }    
}
