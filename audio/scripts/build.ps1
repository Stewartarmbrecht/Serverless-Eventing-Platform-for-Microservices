$microserviceName = "Audio"
$loggingPrefix = "$microserviceName Build"

Set-Location "$PSSCriptRoot/../"

. ./../scripts/functions.ps1

$directoryStart = Get-Location

Set-Location "$directoryStart\src\contentreactor.$microserviceName"
$result = ExecuteCommand "dotnet build" $loggingPrefix "Building the solution."