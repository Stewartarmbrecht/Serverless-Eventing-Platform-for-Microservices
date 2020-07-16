function Build-EdenService
{
    [CmdletBinding()]
    param(
        [switch]$Continuous
    )
    
    try {
        
        $edenEnvConfig = Get-EdenEnvConfig

        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Build"
        
        if ($Continuous) {
            Write-BuildInfo "Building the service continuously." $loggingPrefix
            Invoke-EdenCommand -EdenCommand "Build-ServiceContinuous" -EdenEnvConfig $edenEnvConfig -LoggingPrefix $loggingPrefix
        } else {
            Write-BuildInfo "Building the service." $loggingPrefix
            Invoke-EdenCommand -EdenCommand "Build-Service" -EdenEnvConfig $edenEnvConfig -LoggingPrefix $loggingPrefix
            Write-BuildInfo "Finished building the service." $loggingPrefix
        }
        
    }
    catch
    {
        Write-BuildError "Error building the service. Message: '$($_.Exception.Message)'" $loggingPrefix
        throw $_
    }
}
