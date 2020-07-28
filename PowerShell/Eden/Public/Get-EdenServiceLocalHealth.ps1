function Get-EdenServiceHealth
{
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

        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Operations"
        
        Write-EdenBuildInfo "Getting the local service health." $loggingPrefix
        $result = Invoke-EdenCommand "Get-ServiceHealthLocal" $edenEnvConfig $loggingPrefix
        return $result
    }
    catch
    {
        Write-EdenBuildError "Error getting the local service health. Message: '$($_.Exception.Message)'" $loggingPrefix
        # throw $_
    }
}
New-Alias `
    -Name e-ds `
    -Value Deploy-EdenServiceSubscriptions
