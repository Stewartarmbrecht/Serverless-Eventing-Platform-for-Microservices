function Deploy-EdenServiceInfrastructure {
    [CmdletBinding()]
    param(  
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig -Check
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Deploy Infrastructure $($edenEnvConfig.EnvironmentName)"

        Write-BuildInfo "Deploying the service infrastructure." $loggingPrefix

        Invoke-EdenCommand "Deploy-ServiceInfrastructure" $edenEnvConfig $loggingPrefix
        
        Write-BuildInfo "Finished deploying the service infrastructure." $loggingPrefix
    }
    catch {
        Write-BuildError "Error deploying the service infrastructure. Message: '$($_.Exception.Message)'" $loggingPrefix
        throw $_
    }    
}
