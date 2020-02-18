$microserviceName = "Audio"
$loggingPrefix = "$microserviceName Build"

Set-Location "$PSSCriptRoot/../"

. ./../scripts/functions.ps1

$directoryStart = Get-Location

Set-Location "$directoryStart/src/ContentReactor.$microserviceName"
$result = ExecuteCommand "dotnet build" $loggingPrefix "Building the solution."

Set-Location "$directoryStart/src/ContentReactor.$microserviceName/ContentReactor.$microserviceName.Tests.E2E"
$result = ExecuteCommand "npm install" $loggingPrefix "Installing E2E Project."

