function Show-EdenServiceMonitor {
    [CmdletBinding()]
    param()
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Show Resources"

        Write-EdenBuildInfo "Showing the monitoring dashboards for the service." $loggingPrefix

        Invoke-EdenCommand "Show-ServiceMonitor" $edenEnvConfig $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error launching the service monitor. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-om `
    -Value Show-EdenServiceMonitor
