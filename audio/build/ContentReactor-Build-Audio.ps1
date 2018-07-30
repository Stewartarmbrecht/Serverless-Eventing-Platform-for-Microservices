$microserviceName = "Audio"
$loggingPrefix = "Audio Build"

Set-Location "$PSSCriptRoot/../"

. ./../scripts/ContentReactor-Functions.ps1

$directoryStart = Get-Location

Set-Location "$directoryStart\src\contentreactor.$microserviceName"
ExecuteCommand "dotnet build" $loggingPrefix

Set-Location "$directoryStart\src\contentreactor.$microserviceName\contentreactor.$microserviceName.services.tests"
ExecuteCommand "dotnet test --logger ""trx;logFileName=testResults.trx""" $loggingPrefix

Set-Location "$directoryStart\src\ContentReactor.$microserviceName"
ExecuteCommand "dotnet publish -c Release" $loggingPrefix

$path =  "$directoryStart/src/ContentReactor.$microserviceName/ContentReactor.$microserviceName.Api/bin/Release/netstandard2.0/publish/**"
$destination = "$directoryStart/deploy/ContentReactor.$microserviceName.Api.zip"
ExecuteCommand "Remove-Item -Path $destination -Recurse -Force -ErrorAction Ignore" $loggingPrefix

ExecuteCommand "Compress-Archive -Path $path -Destination $destination" $loggingPrefix

$path =  "$directoryStart/src/ContentReactor.$microserviceName/ContentReactor.$microserviceName.WorkerApi/bin/Release/netstandard2.0/publish/**"
$destination = "$directoryStart/deploy/ContentReactor.$microserviceName.WorkerApi.zip"
ExecuteCommand "Remove-Item -Path $destination -Recurse -Force -ErrorAction Ignore" $loggingPrefix

ExecuteCommand "Compress-Archive -Path $path -Destination $destination" $loggingPrefix

Set-Location "$directoryStart\build"
D "Built $microserviceName Microservice in $(Get-Location)" $loggingPrefix
