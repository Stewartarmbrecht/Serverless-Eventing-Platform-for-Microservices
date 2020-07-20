[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

Write-EdenBuildInfo "Building the ContentReactor.Audio.sln Solution continuously." $LoggingPrefix
dotnet watch --project ./ContentReactor.Audio.sln build ./ContentReactor.Audio.sln