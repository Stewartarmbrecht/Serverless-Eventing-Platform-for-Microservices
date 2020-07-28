function Show-EdenServicePipelineHistory {
    [CmdletBinding()]
    param(
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Show Results"

        Write-EdenBuildInfo "Showing the service pipeline history." $loggingPrefix

        Invoke-EdenCommand "Show-ServicePipelineHistory" $edenEnvConfig $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error showing the service pipeline history. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-ph `
    -Value Show-EdenServicePipelineHistory
