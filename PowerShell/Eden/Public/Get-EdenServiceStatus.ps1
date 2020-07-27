function Get-EdenServiceStatus {
    [CmdletBinding()]
    param(
        [Alias("l")]
        [Switch] $Local,
        [Alias("s")]
        [Switch] $Staging,
        [Alias("p")]
        [Switch] $Production
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Status"

        if ($Local -or (!$Staging -and !$Production)) {
            Write-EdenBuildInfo "Getting the local service status." $loggingPrefix
            Invoke-EdenCommand "Get-ServiceStatusLocal" $edenEnvConfig $loggingPrefix
        }
        if ($Staging) {
            Write-EdenBuildInfo "Getting the staging service status." $loggingPrefix
            Invoke-EdenCommand "Get-ServiceStatusStaging" $edenEnvConfig $loggingPrefix
        }
        if ($Production) {
            Write-EdenBuildInfo "Getting the production service status." $loggingPrefix
            Invoke-EdenCommand "Get-ServiceStatusProduction" $edenEnvConfig $loggingPrefix
        }
    }
    catch {
        Write-EdenBuildError "Error showing the service status. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-os `
    -Value Get-EdenServiceStatus
