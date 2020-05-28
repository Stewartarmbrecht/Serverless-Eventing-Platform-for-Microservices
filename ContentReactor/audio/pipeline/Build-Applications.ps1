[CmdletBinding()]
param(
)

$currentDirectory = Get-Location
Set-Location $PSScriptRoot

. ./Functions.ps1

$loggingPrefix = "ContentReactor Audio Build"

Invoke-BuildCommand "dotnet build ./../ContentReactor.Audio.sln" $loggingPrefix "Building the solution."

Write-BuildInfo "Finished building the solution." $loggingPrefix

Set-Location $currentDirectory
