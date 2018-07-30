$microserviceName = "Text"
$loggingPrefix = "$microserviceName Build"

Set-Location "$PSSCriptRoot/../"

. ./../scripts/functions.ps1

$directoryStart = Get-Location

Set-Location "$directoryStart\src\contentreactor.$microserviceName"
ExecuteCommand "dotnet build" $loggingPrefix "Building the solution."

Set-Location "$directoryStart\src\contentreactor.$microserviceName\contentreactor.$microserviceName.services.tests"
ExecuteCommand "dotnet test --logger ""trx;logFileName=testResults.trx""" $loggingPrefix "Testing the solution"

Set-Location "$directoryStart\src\contentreactor.$microserviceName"
ExecuteCommand "dotnet publish -c Release" $loggingPrefix "Publishing the solution."

$path =  "$directoryStart/src/contentreactor.$microserviceName/contentreactor.$microserviceName.api/bin/release/netstandard2.0/publish/**"
$destination = "$directoryStart/deploy/ContentReactor.$microserviceName.Api.zip"

ExecuteCommand "Remove-Item -Path $destination -Recurse -Force -ErrorAction Ignore" $loggingPrefix "Removing the API package."

ExecuteCommand "Compress-Archive -Path $path -Destination $destination" $loggingPrefix "Creating the API package."

Set-Location "$directoryStart\build"
D "Built the $microserviceName Microservice" $loggingPrefix
