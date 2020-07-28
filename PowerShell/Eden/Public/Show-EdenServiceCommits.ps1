function Show-EdenServiceCommits {
    [CmdletBinding()]
    param()
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Source Control"

        Write-EdenBuildInfo "Showing the Commits made to the service." $loggingPrefix

        Invoke-EdenCommand "Show-ServiceCommits" $edenEnvConfig $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error showing the service Commits. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-scoml `
    -Value Show-EdenServiceCommits
