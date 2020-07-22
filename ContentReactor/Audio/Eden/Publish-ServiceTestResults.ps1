[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

    Write-EdenBuildInfo "Removing test results Allure history folder." $LoggingPrefix
    Remove-Item "./Service.Tests/TestResults/history" -Recurse
    Write-EdenBuildInfo "Finished removing test results Allure history folder." $LoggingPrefix

    Write-EdenBuildInfo "Copying published test results Allure history." $LoggingPrefix
    Copy-Item -Path "./Service.Tests/Reports/Results/history" -Destination "./Service.Tests/TestResults/history" -Recurse -Force
    Write-EdenBuildInfo "Finished copying published test results Allure history." $LoggingPrefix

    Write-EdenBuildInfo "Generating test results report to './Service.Tests/Reports/Results'" $LoggingPrefix
    allure generate ./Service.Tests/TestResults/ -o ./Service.Tests/Reports/Results --clean
    Write-EdenBuildInfo "Finished generating test results report to './Service.Tests/Reports/Results'" $LoggingPrefix