function Show-EdenServiceIssueSubmissionForm {
    [CmdletBinding()]
    param()
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Issues"

        Write-EdenBuildInfo "Showing the product issues submission form for the service." $loggingPrefix

        Invoke-EdenCommand "Show-ServiceIssueSubmission" $edenEnvConfig $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error showing the service issue submission form. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-isf `
    -Value Show-EdenServiceIssueSubmissionForm
