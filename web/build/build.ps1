$microserviceName = "Web"
$loggingPrefix = "$microserviceName Build"

Set-Location "$PSSCriptRoot/../"

. ./../scripts/functions.ps1

$directoryStart = Get-Location

D "Building the Web Application." $loggingPrefix
./build/build-web-app.ps1

# Building the web server.
Set-Location "$directoryStart/src/ContentReactor.Web/ContentReactor.Web.Server"
$result = ExecuteCommand "dotnet build" $loggingPrefix "Building the web server."

# Testing the web server.
Set-Location "$directoryStart/src/ContentReactor.Web/ContentReactor.Web.Tests"
$result = ExecuteCommand "dotnet test --logger ""trx;logFileName=testResults.trx""" $loggingPrefix "Testing the web server."

# Publishing the web server.
Set-Location "$directoryStart/src/ContentReactor.$microserviceName/ContentReactor.$microserviceName.Server"
$result = ExecuteCommand "dotnet publish -c Release -o $directoryStart/.dist/web" $loggingPrefix "Publishing the web server."

$path =  "$directoryStart/.dist/web/"
$destination = "$directoryStart/deploy/.dist/"

# Removing the web server from the deployment folder
$result = ExecuteCommand "Remove-Item -Path $destination -Recurse -Force -ErrorAction Ignore" $loggingPrefix "Removing the web server from the deployment folder."

# Copying the new web server files to the deployment folder.
$result = ExecuteCommand "Copy-Item -Path $path -Destination $destination -Recurse -Force" $loggingPrefix "Copying the new web server files to the deployment folder."

Set-Location "$directoryStart/build"
D "Built the $microserviceName Microservice" $loggingPrefix
