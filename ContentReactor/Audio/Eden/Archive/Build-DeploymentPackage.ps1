[CmdletBinding()]
param(  
)
$currentDirectory = Get-Location
Set-Location $PSScriptRoot

. ./Functions.ps1

$loggingPrefix = "ContentReactor Audio Package"

Set-Location "$PSSCriptRoot/../"

$directoryStart = Get-Location

Write-EdenBuildInfo "Packaging the service application." $loggingPrefix

Set-Location "$directoryStart/Service"
Invoke-BuildCommand "dotnet publish -c Release -o $directoryStart/.dist/app" $loggingPrefix "Publishing the function application."

$appPath =  "$directoryStart/.dist/app/**"
$appDestination = "$directoryStart/.dist/app.zip"

Write-EdenBuildInfo "Removing the app package." $loggingPrefix
Remove-Item -Path $appDestination -Recurse -Force -ErrorAction Ignore

Write-EdenBuildInfo "Creating the app package." $loggingPrefix
Compress-Archive -Path $appPath -DestinationPath $appDestination

Write-EdenBuildInfo "Packaged the oservice." $loggingPrefix
Set-Location $currentDirectory
