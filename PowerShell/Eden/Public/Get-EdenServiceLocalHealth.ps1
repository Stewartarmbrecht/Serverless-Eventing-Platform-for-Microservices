function Get-EdenServiceLocalHealth
{
    [CmdletBinding()]
    param()
    
    try {
        
        $edenEnvConfig = Get-EdenEnvConfig

        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Test Unit"
        
        Write-EdenBuildInfo "Getting the local service health." $loggingPrefix
        $result = Invoke-EdenCommand "Get-LocalServiceHealth" $edenEnvConfig $loggingPrefix
        return $result
    }
    catch
    {
        Write-EdenBuildError "Error getting the local service health. Message: '$($_.Exception.Message)'" $loggingPrefix
        # throw $_
    }
}
