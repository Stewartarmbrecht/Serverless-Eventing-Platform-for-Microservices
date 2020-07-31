function Get-EdenServiceStatus
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
        
        Write-EdenBuildInfo "Getting the local service status." $loggingPrefix
        $result = Invoke-EdenCommand "Get-ServiceStatusLocal" $edenEnvConfig $loggingPrefix
        return $result
    }
    catch
    {
        Write-EdenBuildError "Error getting the local service status. Message: '$($_.Exception.Message)'" $loggingPrefix
        # throw $_
    }
}
New-Alias `
    -Name e-os `
    -Value Get-EdenServiceStatus
