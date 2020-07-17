function Publish-EdenService {
    [CmdletBinding()]
    param(  
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig -Check
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Publish"

        Write-BuildInfo "Publishing the service." $loggingPrefix

        Invoke-EdenCommand "Publish-Service" $edenEnvConfig $loggingPrefix
        
        Write-BuildInfo "Finished publishing the service." $loggingPrefix
    }
    catch {
        Write-BuildError "Error publishing the service. Message: '$($_.Exception.Message)'" $loggingPrefix
        throw $_
    }    
}
