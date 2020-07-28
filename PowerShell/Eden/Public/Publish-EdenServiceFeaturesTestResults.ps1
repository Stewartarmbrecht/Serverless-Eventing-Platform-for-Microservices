function Publish-EdenServiceFeaturesTestResults {
    [CmdletBinding()]
    param(  
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig -Check
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Publish Results"

        Write-EdenBuildInfo "Publishing the service feature test results." $loggingPrefix

        Invoke-EdenCommand "Publish-ServiceFeaturesTestResults" $edenEnvConfig $loggingPrefix
        
        Write-EdenBuildInfo "Finished publishing the service feature test results." $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error publishing the service feature test results. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-tftrp `
    -Value Publish-EdenServiceFeaturesTestResults
