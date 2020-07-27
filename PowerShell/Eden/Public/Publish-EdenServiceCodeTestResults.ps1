function Publish-EdenServiceCodeTestResults {
    [CmdletBinding()]
    param(  
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig -Check
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Publish Results"

        Write-EdenBuildInfo "Publishing the service code test results." $loggingPrefix

        Invoke-EdenCommand "Publish-ServiceCodeTestResults" $edenEnvConfig $loggingPrefix
        
        Write-EdenBuildInfo "Finished publishing the service code test results." $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error publishing the service code test results. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-tctrp `
    -Value Publish-EdenServiceCodeTestResults
