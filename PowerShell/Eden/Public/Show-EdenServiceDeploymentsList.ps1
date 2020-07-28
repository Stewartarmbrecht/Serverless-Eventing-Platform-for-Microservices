function Show-EdenServiceDeploymentsList {
    [CmdletBinding()]
    param()
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Deployments"

        Write-EdenBuildInfo "Showing the deployments list for the service." $loggingPrefix

        Invoke-EdenCommand "Show-ServiceDeploymentsList" $edenEnvConfig $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error showing the service deployments list. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-dl `
    -Value Show-EdenServiceDeploymentsList
