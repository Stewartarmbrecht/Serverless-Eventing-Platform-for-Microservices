function Test-EdenServicePerformance
{
    [CmdletBinding()]
    param(
    )

    $edenEnvConfig = Get-EdenEnvConfig -Check
    $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Test Staging $($edenEnvConfig.EnvironmentName)"
    Write-EdenBuildInfo "Testing the service Performance." $loggingPrefix
    Invoke-EdenCommand "Test-ServicePerformance" $edenEnvConfig $loggingPrefix
    Write-EdenBuildInfo "Finished testing the service Performance." $loggingPrefix
}
New-Alias `
    -Name e-tp `
    -Value Test-EdenServicePerformance
