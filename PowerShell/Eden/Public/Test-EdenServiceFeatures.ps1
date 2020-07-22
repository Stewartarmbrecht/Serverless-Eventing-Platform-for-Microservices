function Test-EdenServiceFeatures
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [Switch]$Continuous,
        [Parameter()]
        [Switch]$BuildOnce,
        [Parameter()]
        [Switch]$Staging
    )

    if ($Staging) {
        $edenEnvConfig = Get-EdenEnvConfig -Check
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Test Staging $($edenEnvConfig.EnvironmentName)"
        Write-EdenBuildInfo "Testing the staging service features." $loggingPrefix
        Invoke-EdenCommand "Test-ServiceFeaturesStaging" $edenEnvConfig $loggingPrefix
        Write-EdenBuildInfo "Finished testing the staging service features." $loggingPrefix
    } else {
        Start-EdenServiceLocal -Continuous:($Continuous -and !$BuildOnce) -RunFeatureTests:(!$Continuous) -RunFeatureTestsContinuously:($Continuous)
    }
}
