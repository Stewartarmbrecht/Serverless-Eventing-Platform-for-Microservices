$microserviceName = "Health"
$loggingPrefix = "$microserviceName Build"

$location = Get-Location

Set-Location "$PSSCriptRoot/../"

. ./../scripts/functions.ps1

$directoryStart = Get-Location

Set-Location "$directoryStart/src/contentreactor.$microserviceName"
$results = ExecuteCommand "dotnet build" $loggingPrefix "Building the solution."

Write-Host $results;

Set-Location "$directoryStart/src/contentreactor.$microserviceName/contentreactor.$microserviceName.Tests.E2E"
$results = ExecuteCommand "npm install" $loggingPrefix "Installing the e2e project."

Write-Host $results;

Set-Location $location