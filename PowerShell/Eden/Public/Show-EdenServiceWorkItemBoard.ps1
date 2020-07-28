function Show-EdenServiceWorkItemBoard {
    [CmdletBinding()]
    param()
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Show Resources"

        Write-EdenBuildInfo "Showing the work item board for the service." $loggingPrefix

        Invoke-EdenCommand "Show-ServiceWorkItemBoard" $edenEnvConfig $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error showing the service work item board. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-wib `
    -Value Show-EdenServiceWorkItemBoard
