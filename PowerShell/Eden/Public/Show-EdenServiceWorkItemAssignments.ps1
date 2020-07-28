function Show-EdenServiceWorkItemAssignments {
    [CmdletBinding()]
    param()
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Show Resources"

        Write-EdenBuildInfo "Showing the product work item assignments for the service." $loggingPrefix

        Invoke-EdenCommand "Show-ServiceWorkItemAssignments" $edenEnvConfig $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error showing the service work item assignments. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-wia `
    -Value Show-EdenServiceWorkItemAssignments
