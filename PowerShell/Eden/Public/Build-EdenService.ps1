function Build-EdenService
{
    [CmdletBinding()]
    param(
        [Alias("c")]
        [switch]$Continuous
    )
    
    try {
        
        $edenEnvConfig = Get-EdenEnvConfig

        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Build"
        
        if ($Continuous) {
            Write-EdenBuildInfo "Building the service continuously." $loggingPrefix
            Invoke-EdenCommand -EdenCommand "Build-ServiceContinuous" -EdenEnvConfig $edenEnvConfig -LoggingPrefix $loggingPrefix
        } else {
            Write-EdenBuildInfo "Building the service." $loggingPrefix
            Invoke-EdenCommand -EdenCommand "Build-Service" -EdenEnvConfig $edenEnvConfig -LoggingPrefix $loggingPrefix
            Write-EdenBuildInfo "Finished building the service." $loggingPrefix
        }
        
    }
    catch
    {
        Write-EdenBuildError "Error building the service. Message: '$($_.Exception.Message)'" $loggingPrefix
    }
}
New-Alias `
    -Name e-b `
    -Value Build-EdenService
