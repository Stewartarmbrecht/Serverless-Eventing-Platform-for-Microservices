[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

    Write-EdenBuildInfo "Launching a browser to load the published code coverage report at './Service.Tests/Reports/Coverage/index.html'." $LoggingPrefix
    Start-Process "./Service.Tests/Reports/Coverage/index.html"