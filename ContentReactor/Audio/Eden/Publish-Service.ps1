[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

Write-EdenBuildInfo "Publishing the function application to './.dist/app'." $LoggingPrefix
dotnet publish ./Service/ContentReactor.Audio.Service.csproj -c Release -o ./.dist/app

$appPath =  "./.dist/app/**"
$appDestination = "./.dist/app.zip"

Write-EdenBuildInfo "Removing the app package: './.dist/app.zip'." $LoggingPrefix
Remove-Item -Path $appDestination -Recurse -Force -ErrorAction Ignore

Write-EdenBuildInfo "Creating the app package: './.dist/app.zip'." $LoggingPrefix
Compress-Archive -Path $appPath -DestinationPath $appDestination