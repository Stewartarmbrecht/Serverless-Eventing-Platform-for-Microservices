function Deploy-EdenServiceSubscriptions {
    [CmdletBinding()]
    param(  
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig -Check
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Deploy Subscriptions $($edenEnvConfig.EnvironmentName)"

        Write-EdenBuildInfo "Deploying the service subscriptions." $loggingPrefix

        Invoke-EdenCommand "Deploy-ServiceSubscriptions" $edenEnvConfig $loggingPrefix
        
        Write-EdenBuildInfo "Finished deploying the service subscriptions." $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error deploying the service subscriptions. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
