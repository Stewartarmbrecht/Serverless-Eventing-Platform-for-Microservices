function Show-EdenServiceDocs {
    [CmdletBinding()]
    param(
        [Alias("f")]
        [Switch] $Functional,
        [Alias("r")]
        [Switch] $Reference,
        [Alias("a")]
        [Switch] $Architecture,
        [Alias("i")]
        [Switch] $Infrasrtructure,
        [Alias("o")]
        [Switch] $Operations,
        [Alias("t")]
        [Switch] $Team,
        [Alias("c")]
        [Switch] $Chat,
        [Alias("b")]
        [Switch] $Bot
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Documentation"

        if($Functional) {
            Write-EdenBuildInfo "Showing the functional documentation for the service." $loggingPrefix
            Invoke-EdenCommand "Show-ServiceDocsFunc" $edenEnvConfig $loggingPrefix    
        } elseif ($Reference) {
            Write-EdenBuildInfo "Showing the reference documentation for the service." $loggingPrefix
            Invoke-EdenCommand "Show-ServiceDocsRef" $edenEnvConfig $loggingPrefix    
        } elseif ($Architecture) {
            Write-EdenBuildInfo "Showing the architecture documentation for the service." $loggingPrefix
            Invoke-EdenCommand "Show-ServiceDocsArch" $edenEnvConfig $loggingPrefix    
        } elseif ($Infrasrtructure) {
            Write-EdenBuildInfo "Showing the infrastructure documentation for the service." $loggingPrefix
            Invoke-EdenCommand "Show-ServiceDocsInfra" $edenEnvConfig $loggingPrefix    
        } elseif ($Operations) {
            Write-EdenBuildInfo "Showing the operations documentation for the service." $loggingPrefix
            Invoke-EdenCommand "Show-ServiceDocsOps" $edenEnvConfig $loggingPrefix    
        } elseif ($Team) {
            Write-EdenBuildInfo "Showing the team documentation for the service." $loggingPrefix
            Invoke-EdenCommand "Show-ServiceDocsTeam" $edenEnvConfig $loggingPrefix    
        } elseif ($Chat) {
            Write-EdenBuildInfo "Showing the chat documentation for the service." $loggingPrefix
            Invoke-EdenCommand "Show-ServiceDocsChat" $edenEnvConfig $loggingPrefix    
        } elseif ($Bot) {
            Write-EdenBuildInfo "Showing the bots documentation for the service." $loggingPrefix
            Invoke-EdenCommand "Show-ServiceDocsBots" $edenEnvConfig $loggingPrefix    
        } else {
            Write-EdenBuildInfo "Showing the documentation for the service." $loggingPrefix
            Invoke-EdenCommand "Show-ServiceDocs" $edenEnvConfig $loggingPrefix    
        }
    }
    catch {
        Write-EdenBuildError "Error showing the service documentation. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-docs `
    -Value Show-EdenServiceDocs
