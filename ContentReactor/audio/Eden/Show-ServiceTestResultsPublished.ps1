[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

    Write-EdenBuildInfo "Useing Allure Framework to open the published test results report at './Service.Tests/Reports/Results'." $LoggingPrefix
    allure open ./Service.Tests/Reports/Results