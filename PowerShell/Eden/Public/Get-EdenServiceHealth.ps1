function Get-EdenServiceHealth {
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
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Health"

        if ($Local -or (!$Staging -and !$Production)) {
            Write-EdenBuildInfo "Getting the local service health." $loggingPrefix
            Invoke-EdenCommand "Get-ServiceHealthLocal" $edenEnvConfig $loggingPrefix
        }
        if ($Staging) {
            Write-EdenBuildInfo "Getting the staging service Health." $loggingPrefix
            Invoke-EdenCommand "Get-ServiceHealthStaging" $edenEnvConfig $loggingPrefix
        }
        if ($Production) {
            Write-EdenBuildInfo "Getting the production service Health." $loggingPrefix
            Invoke-EdenCommand "Get-ServiceHealthProduction" $edenEnvConfig $loggingPrefix
        }
    }
    catch {
        Write-EdenBuildError "Error showing the service Health. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-oh `
    -Value Get-EdenServiceHealth
