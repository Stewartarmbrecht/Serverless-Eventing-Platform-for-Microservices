[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

Write-EdenBuildInfo "Setting the target url for the features test to: 'http://localhost:7071/api/audio'." $LoggingPrefix
$Env:FeaturesUrl = "http://localhost:7071/api/audio"

Write-EdenBuildInfo "Running the tests in the Serivce.Tests/ContentReactor.Audio.Service.Tests.csproj project that are tagged as Features." $LoggingPrefix
dotnet test ./Service.Tests/ContentReactor.Audio.Service.Tests.csproj --filter TestCategory=Features
