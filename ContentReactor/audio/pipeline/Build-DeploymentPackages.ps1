[CmdletBinding()]
param(  
)
$currentDirectory = Get-Location
Set-Location $PSScriptRoot

. ./Functions.ps1

$loggingPrefix = "ContentReactor Audio Package"

Set-Location "$PSSCriptRoot/../"

$directoryStart = Get-Location

Write-BuildInfo "Packaging the microservice." $loggingPrefix

Set-Location "$directoryStart/api"
Invoke-BuildCommand "dotnet publish -c Release -o $directoryStart/.dist/api" $loggingPrefix "Publishing the api application."

Set-Location "$directoryStart/worker"
Invoke-BuildCommand "dotnet publish -c Release -o $directoryStart/.dist/worker" $loggingPrefix "Publishing the worker application."

$apiPath =  "$directoryStart/.dist/api/**"
$apiDestination = "$directoryStart/.dist/api.zip"

Write-BuildInfo "Removing the api package." $loggingPrefix
Remove-Item -Path $apiDestination -Recurse -Force -ErrorAction Ignore

Write-BuildInfo "Creating the api package." $loggingPrefix
Compress-Archive -Path $apiPath -DestinationPath $apiDestination

$workerPath = "$directoryStart/.dist/worker/**"
$workerDestination = "$directoryStart/.dist/worker.zip"

Write-BuildInfo "Removing the worker package." $loggingPrefix
Remove-Item -Path $workerDestination -Recurse -Force -ErrorAction Ignore

Write-BuildInfo "Creating the worker package." $loggingPrefix
Compress-Archive -Path $workerPath -DestinationPath $workerDestination

Write-BuildInfo "Packaged the Audio microservice." $loggingPrefix
Set-Location $currentDirectory
