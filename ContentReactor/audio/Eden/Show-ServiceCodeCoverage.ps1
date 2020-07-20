[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

    Write-EdenBuildInfo "Launching a browser to load the code coverage report at './Service.Tests/TestResults/coveragereport/index.html'." $LoggingPrefix
    Start-Process "./Service.Tests/TestResults/coveragereport/index.html"