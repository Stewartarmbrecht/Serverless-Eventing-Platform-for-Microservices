[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

    Write-EdenBuildInfo "Publishing code coverage reports to './Service.Tests/Reports/Coverage'" $LoggingPrefix
    reportgenerator "-reports:./Service.Tests/TestResults/Coverage.info" "-targetdir:Service.Tests/Reports/Coverage" -reporttypes:Html
    Write-EdenBuildInfo "Finished publishing code coverage reports to './Service.Tests/Reports/Coverage'" $LoggingPrefix   