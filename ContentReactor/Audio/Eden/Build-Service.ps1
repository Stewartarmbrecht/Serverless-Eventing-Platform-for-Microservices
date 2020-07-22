[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

    Write-EdenBuildInfo "Building the ContentReactor.Audio.sln Solution." $LoggingPrefix
    dotnet build ./ContentReactor.Audio.sln
    Write-EdenBuildInfo "Finished building the ContentReactor.Audio.sln Solution." $LoggingPrefix
