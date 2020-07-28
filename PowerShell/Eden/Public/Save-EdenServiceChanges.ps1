function Save-EdenServiceChanges {
    [CmdletBinding()]
    param()
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Save Resources"

        Write-EdenBuildInfo "Saving the changes made to the service." $loggingPrefix

        Invoke-EdenCommand "Save-ServiceChanges" $edenEnvConfig $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error saving the service changes. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-schsv `
    -Value Save-EdenServiceChanges
