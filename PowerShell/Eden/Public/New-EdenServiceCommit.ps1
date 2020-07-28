function New-EdenServiceCommit {
    [CmdletBinding()]
    param()
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) New Commit"

        Write-EdenBuildInfo "Commit the changes made to the service." $loggingPrefix

        Invoke-EdenCommand "New-ServiceCommit" $edenEnvConfig $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error committing the changes made to the service. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-scomn `
    -Value New-EdenServiceCommit
