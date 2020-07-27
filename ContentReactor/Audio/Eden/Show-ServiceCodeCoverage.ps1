[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

    Write-EdenBuildInfo "Launching a browser to load the code coverage report at './Service.Tests/TestResults/Coverage/index.html'." $LoggingPrefix

    Write-Host "" -ForegroundColor Blue
    Write-Host "Click: http://localhost:8088/Service.Tests/TestResults/Coverage" -ForegroundColor Blue
    Write-Host "" -ForegroundColor Blue
    live-server --port=8088

