$microserviceName = "Web"
$loggingPrefix = "$microserviceName Build"

Set-Location "$PSSCriptRoot/../"

. ./../scripts/functions.ps1

$directoryStart = Get-Location

D "Building the Web Application." $loggingPrefix
./build/build-web-app.ps1

Set-Location "$directoryStart/src/contentreactor.$microserviceName"
$results = ExecuteCommand "dotnet build" $loggingPrefix "Building the solution."