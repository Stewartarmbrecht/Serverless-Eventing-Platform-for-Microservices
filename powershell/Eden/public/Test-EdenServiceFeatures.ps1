function Test-EdenServiceFeatures
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [Switch]$Continuous,
        [Parameter()]
        [Switch]$BuildOnce
    )
    Start-EdenServiceLocal -Continuous:($Continuous -and !$BuildOnce) -RunFeatureTests:(!$Continuous) -RunFeatureTestsContinuously:($Continuous)
}
