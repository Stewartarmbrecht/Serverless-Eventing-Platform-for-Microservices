$microserviceName = "Web Server"
$loggingPrefix = "$microserviceName Build"

Set-Location "$PSSCriptRoot/../"

. ./../scripts/functions.ps1

$directoryStart = Get-Location

Set-Location "$directoryStart/src/ContentReactor.Web/ContentReactor.Web.Server"

ExecuteCommand "dotnet build" $loggingPrefix "Building the web server."

Set-Location "$directoryStart/src/ContentReactor.Web/ContentReactor.Web.Tests"

ExecuteCommand "dotnet test --logger ""trx;logFileName=testResults.trx""" $loggingPrefix "Testing the web server."

Set-Location "$directoryStart/src/ContentReactor.Web/ContentReactor.Web.Server"

ExecuteCommand "dotnet publish -c Release" $loggingPrefix "Publishing the web server."

$path = "$directoryStart/src/ContentReactor.Web/ContentReactor.Web.Server/bin/Release/netcoreapp2.1/publish/**"
$destination = "$directoryStart/deploy/.dist/"

ExecuteCommand "Remove-Item -Path $destination -Recurse -Force -ErrorAction Ignore" $loggingPrefix "Removeing the web server from the deployment folder."

ExecuteCommand "Copy-Item -Path $path -Destination $destination -Recurse -Force" $loggingPrefix "Copying the new web server files to the deployment folder."

Set-Location "$directoryStart/build"
D "Built the $microserviceName Microservice" $loggingPrefix
