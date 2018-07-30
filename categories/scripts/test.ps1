$microserviceName = "Categories"
$loggingPrefix = "$microserviceName Test"

Set-Location "$PSSCriptRoot/../"

. ./../scripts/functions.ps1

$directoryStart = Get-Location

Set-Location "$directoryStart\src\contentreactor.$microserviceName"
ExecuteCommand "dotnet build" $loggingPrefix "Building the solution."

Set-Location "$directoryStart\src\contentreactor.$microserviceName\contentreactor.$microserviceName.services.tests"
ExecuteCommand "dotnet test --logger ""trx;logFileName=testResults.trx""" $loggingPrefix "Testing the solution"

