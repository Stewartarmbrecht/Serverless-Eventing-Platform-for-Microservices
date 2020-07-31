function Get-EdenServiceUrlPublicLocal
{
    [CmdletBinding()]
    param()
    
    try {
        
        $edenEnvConfig = Get-EdenEnvConfig

        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Test Unit"
        
        Write-EdenBuildInfo "Getting the local service health." $loggingPrefix
        $result = Invoke-EdenCommand "Get-ServiceUrlPublicLocal" $edenEnvConfig $loggingPrefix
        return $result
    }
    catch
    {
        Write-EdenBuildError "Error getting the local service health. Message: '$($_.Exception.Message)'" $loggingPrefix
        # throw $_
    }
}
New-Alias `
    -Name e-hupl `
    -Value Get-EdenServiceUrlPublicLocal
