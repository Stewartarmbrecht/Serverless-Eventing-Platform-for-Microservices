[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

Write-EdenBuildInfo "Using Allure Framework to open the test results report at './Service.Tests/TestResults/Allure'." $LoggingPrefix
Write-Host "" -ForegroundColor Blue
Write-Host "Click: http://localhost:9091/" -ForegroundColor Blue
Write-Host "" -ForegroundColor Blue

allure open ./Service.Tests/Reports/Results -p 9091
