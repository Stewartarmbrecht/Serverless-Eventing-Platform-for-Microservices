function Show-EdenServicePipelineReport {
    [CmdletBinding()]
    param(
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Show Results"

        Write-EdenBuildInfo "Launching the service pipeline report." $loggingPrefix

        Invoke-EdenCommand "Show-ServicePipelineReport" $edenEnvConfig $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error launching the service pipeline report. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-pr `
    -Value Show-EdenServicePipelineReport
