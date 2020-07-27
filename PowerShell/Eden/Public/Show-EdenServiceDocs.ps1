function Show-EdenServiceDocs {
    [CmdletBinding()]
    param()
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Show Resources"

        Write-EdenBuildInfo "Showing the documentation for the service." $loggingPrefix

        Invoke-EdenCommand "Show-ServiceDocs" $edenEnvConfig $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error showing the service documentation. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-docs `
    -Value Show-EdenServiceDocs
