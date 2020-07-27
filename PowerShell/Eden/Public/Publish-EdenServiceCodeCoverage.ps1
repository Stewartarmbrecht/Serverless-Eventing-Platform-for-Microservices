function Publish-EdenServiceCodeCoverage {
    [CmdletBinding()]
    param(  
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig -Check
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Publish Coverage"

        Write-EdenBuildInfo "Publishing the service code coverage results." $loggingPrefix

        Invoke-EdenCommand "Publish-ServiceCodeCoverage" $edenEnvConfig $loggingPrefix
        
        Write-EdenBuildInfo "Finished publishing the service code coverage results." $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error publishing the service code coverage results. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-tcccp `
    -Value Publish-EdenServiceCodeCoverage
