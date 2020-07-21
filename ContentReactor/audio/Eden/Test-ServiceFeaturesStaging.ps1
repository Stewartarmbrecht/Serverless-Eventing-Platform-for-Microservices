[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

$apiName = "$($EdenEnvConfig.EnvironmentName)-audio".ToLower()
Write-EdenBuildInfo "Setting the target url for the features test to: 'https://$apiName-staging.azurewebsites.net/api/audio'." $LoggingPrefix
$Env:FeaturesUrl = "https://$apiName-staging.azurewebsites.net/api/audio"

Write-EdenBuildInfo "Running the tests in the Serivce.Tests/ContentReactor.Audio.Service.Tests.csproj project that are tagged as Features." $LoggingPrefix
dotnet test ./Service.Tests/ContentReactor.Audio.Service.Tests.csproj --filter TestCategory=Features
