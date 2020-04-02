$microserviceName = "Audio"
$loggingPrefix = "$microserviceName Build"

$currentDirectory = Get-Location

Set-Location "$PSSCriptRoot/../"

. ./../scripts/functions.ps1

$directoryStart = Get-Location

Set-Location "$directoryStart/src/ContentReactor.$microserviceName"
ExecuteCommand "dotnet build" $loggingPrefix "Building the solution."

Set-Location $currentDirectory