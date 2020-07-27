function Deploy-EdenServiceInfrastructure {
    [CmdletBinding()]
    param(  
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig -Check
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Deploy Infrastructure $($edenEnvConfig.EnvironmentName)"

        Write-EdenBuildInfo "Deploying the service infrastructure." $loggingPrefix

        Invoke-EdenCommand "Deploy-ServiceInfrastructure" $edenEnvConfig $loggingPrefix
        
        Write-EdenBuildInfo "Finished deploying the service infrastructure." $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error deploying the service infrastructure. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-di `
    -Value Deploy-EdenServiceInfrastructure
