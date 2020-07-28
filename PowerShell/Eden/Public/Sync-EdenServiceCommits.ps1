function Sync-EdenServiceCommits {
    [CmdletBinding()]
    param()
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Sync Resources"

        Write-EdenBuildInfo "Syncing the Commits made to the service." $loggingPrefix

        Invoke-EdenCommand "Sync-ServiceCommits" $edenEnvConfig $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error Syncing the service Commits. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-scoms `
    -Value Sync-EdenServiceCommits
