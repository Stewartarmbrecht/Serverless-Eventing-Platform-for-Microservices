function Show-EdenServiceWorkItemList {
    [CmdletBinding()]
    param()
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Show Resources"

        Write-EdenBuildInfo "Showing the product work item list for the service." $loggingPrefix

        Invoke-EdenCommand "Show-ServiceWorkItemList" $edenEnvConfig $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error showing the service work item list. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-wil `
    -Value Show-EdenServiceWorkItemList
