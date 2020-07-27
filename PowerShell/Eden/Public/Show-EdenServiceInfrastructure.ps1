function Show-EdenServiceInfrastructure {
    [CmdletBinding()]
    param()
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Show Resources"

        Write-EdenBuildInfo "Showing the infrastructure for the service." $loggingPrefix

        Invoke-EdenCommand "Show-ServiceInfrastructure" $edenEnvConfig $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error showing the service infrastructure. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-oi `
    -Value Show-EdenServiceInfrastructure
