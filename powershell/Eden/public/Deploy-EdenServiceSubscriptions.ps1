function Deploy-EdenServiceSubscriptions {
    [CmdletBinding()]
    param(  
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig -Check
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Deploy Subscriptions $($edenEnvConfig.EnvironmentName)"

        Write-BuildInfo "Deploying the service subscriptions." $loggingPrefix

        Invoke-EdenCommand "Deploy-ServiceSubscriptions" $edenEnvConfig $loggingPrefix
        
        Write-BuildInfo "Finished deploying the service subscriptions." $loggingPrefix
    }
    catch {
        Write-BuildError "Error deploying the service subscriptions. Message: '$($_.Exception.Message)'" $loggingPrefix
        throw $_
    }    
}
