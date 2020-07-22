[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

    Write-EdenBuildInfo "Useing Allure Framework to open the test results report at './Service.Tests/TestResults/Allure'." $LoggingPrefix
    allure open ./Service.Tests/TestResults/Allure