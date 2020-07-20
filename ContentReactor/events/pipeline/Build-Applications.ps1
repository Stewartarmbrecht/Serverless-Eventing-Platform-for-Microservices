[CmdletBinding()]
param(
)

$currentDirectory = Get-Location
Set-Location $PSScriptRoot

. ./Functions.ps1

$loggingPrefix = "ContentReactor Events Build"

Invoke-BuildCommand "dotnet build ./../ContentReactor.Events.sln" $loggingPrefix "Building the solution."

Write-EdenBuildInfo "Finished building the solution." $loggingPrefix

Set-Location $currentDirectory
