function Show-EdenServiceChanges {
    [CmdletBinding()]
    param()
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Source Control"

        Write-EdenBuildInfo "Showing the changes made to the service." $loggingPrefix

        Invoke-EdenCommand "Show-ServiceChanges" $edenEnvConfig $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error showing the service changes. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-sch `
    -Value Show-EdenServiceChanges
