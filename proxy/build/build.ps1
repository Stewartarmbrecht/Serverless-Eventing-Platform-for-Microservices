$microserviceName = "Proxy"
$loggingPrefix = "$microserviceName Build"

Set-Location "$PSSCriptRoot/../"

. ./../scripts/functions.ps1

$directoryStart = Get-Location

$path =  "$directoryStart/src/proxies/**"
$destination = "$directoryStart/deploy/ContentReactor.$microserviceName.Api.zip"

ExecuteCommand "Remove-Item -Path $destination -Recurse -Force -ErrorAction Ignore" $loggingPrefix "Removing the API package."

ExecuteCommand "Compress-Archive -Path $path -Destination $destination" $loggingPrefix "Creating the API package."

Set-Location "$directoryStart\build"
D "Built the $microserviceName Microservice" $loggingPrefix
