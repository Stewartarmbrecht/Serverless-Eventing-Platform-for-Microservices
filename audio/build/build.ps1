$microserviceName = "Audio"
$loggingPrefix = "Audio Build"

Set-Location "$PSSCriptRoot/../"

. ./../../scripts/functions.ps1

$directoryStart = Get-Location

Set-Location "$directoryStart/src/ContentReactor.$microserviceName"
ExecuteCommand "dotnet build" $loggingPrefix "Building the solution."

Set-Location "$directoryStart/src/ContentReactor.$microserviceName/ContentReactor.$microserviceName.Services.Tests"
ExecuteCommand "dotnet test --logger ""trx;logFileName=testResults.trx"" --filter TestCategory!=E2E" $loggingPrefix "Testing the solution."

Set-Location "$directoryStart/src/ContentReactor.$microserviceName/ContentReactor.$microserviceName.Api"
ExecuteCommand "dotnet publish -c Release -o $directoryStart/.dist/api" $loggingPrefix "Publishing the api application."

Set-Location "$directoryStart/src/ContentReactor.$microserviceName/ContentReactor.$microserviceName.WorkerApi"
ExecuteCommand "dotnet publish -c Release -o $directoryStart/.dist/worker" $loggingPrefix "Publishing the worker application."

$apiPath =  "$directoryStart/.dist/api/**"
$apiDestination = "$directoryStart/deploy/ContentReactor.$microserviceName.Api.zip"
ExecuteCommand "Remove-Item -Path $apiDestination -Recurse -Force -ErrorAction Ignore" $loggingPrefix "Removing the API package."

ExecuteCommand "Compress-Archive -Path $apiPath -DestinationPath $apiDestination" $loggingPrefix "Creating the API package."

$workerPath =  "$directoryStart/.dist/worker/**"
$workerDestination = "$directoryStart/deploy/ContentReactor.$microserviceName.WorkerApi.zip"
ExecuteCommand "Remove-Item -Path $workerDestination -Recurse -Force -ErrorAction Ignore" $loggingPrefix "Removeing the worker package."

ExecuteCommand "Compress-Archive -Path $workerPath -DestinationPath $workerDestination" $loggingPrefix "Creating the worker package."

Set-Location "$directoryStart/build"
D "Built the $microserviceName Microservice" $loggingPrefix
