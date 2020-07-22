function Test-EdenServiceCode
{
    [CmdletBinding()]
    param(
        [switch]$Continuous
    )
    
    try {
        
        $edenEnvConfig = Get-EdenEnvConfig

        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Test Unit"
        
        if ($Continuous) {
            Write-EdenBuildInfo "Testing the service code continuously." $loggingPrefix
            Invoke-EdenCommand "Test-ServiceCodeContinuously" $edenEnvConfig $loggingPrefix
        } else {
            Write-EdenBuildInfo "Testing the service code." $loggingPrefix
            Invoke-EdenCommand "Test-ServiceCode" $edenEnvConfig $loggingPrefix
            Write-EdenBuildInfo "Finished testing the service code." $loggingPrefix
        }
        
    }
    catch
    {
        Write-EdenBuildError "Error testing the service code. Message: '$($_.Exception.Message)'" $loggingPrefix
    }
}
