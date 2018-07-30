$microserviceName = "Proxy"
$loggingPrefix = "$microserviceName Build"

Set-Location "$PSSCriptRoot/../"

. ./../scripts/functions.ps1

$directoryStart = Get-Location

$path =  "$directoryStart/src/**"
$destination = "$directoryStart/deploy/ContentReactor.$microserviceName.Api.zip"

$result = ExecuteCommand "Remove-Item -Path $destination -Recurse -Force -ErrorAction Ignore" $loggingPrefix "Removing the API package."

$result = ExecuteCommand "Compress-Archive -Path $path -DestinationPath $destination" $loggingPrefix "Creating the API package."

Set-Location "$directoryStart\build"
D "Built the $microserviceName Microservice" $loggingPrefix
