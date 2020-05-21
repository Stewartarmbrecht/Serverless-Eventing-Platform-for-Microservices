param(  
    [Alias("c")]
    [Boolean] $continuous,
    [Alias("v")]
    [String] $verbosity
)
$currentDirectory = Get-Location

Set-Location "$PSSCriptRoot"

$location = Get-Location

. ./functions.ps1

./configure-env.ps1

$systemName = $Env:systemName
$solutionName = $Env:solutionName
$microserviceName = $Env:microserviceName
$apiPort = $Env:apiPort
$workerPort = $Env:workerPort

$loggingPrefix = "$systemName $microserviceName Package"

Set-Location "$PSSCriptRoot/../"

$directoryStart = Get-Location

D "Packaging the $microserviceName microservice." $loggingPrefix

Set-Location "$directoryStart/$microserviceName/api"
$result = ExecuteCommand "dotnet publish -c Release -o $directoryStart/$microserviceName/.dist/api" $loggingPrefix "Publishing the api application."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

Set-Location "$directoryStart/$microserviceName/worker"
$result = ExecuteCommand "dotnet publish -c Release -o $directoryStart/$microserviceName/.dist/worker" $loggingPrefix "Publishing the worker application."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

$apiPath =  "$directoryStart/$microserviceName/.dist/api/**"
$apiDestination = "$directoryStart/$microserviceName/.dist/api.zip"
$result = ExecuteCommand "Remove-Item -Path $apiDestination -Recurse -Force -ErrorAction Ignore" $loggingPrefix "Removing the API package."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

$result = ExecuteCommand "Compress-Archive -Path $apiPath -DestinationPath $apiDestination" $loggingPrefix "Creating the API package."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

$workerPath =  "$directoryStart/$microserviceName/.dist/worker/**"
$workerDestination = "$directoryStart/$microserviceName/.dist/worker.zip"
$result = ExecuteCommand "Remove-Item -Path $workerDestination -Recurse -Force -ErrorAction Ignore" $loggingPrefix "Removing the worker package."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

$result = ExecuteCommand "Compress-Archive -Path $workerPath -DestinationPath $workerDestination" $loggingPrefix "Creating the worker package."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

Set-Location $currentDirectory
D "Packaged the $microserviceName microservice." $loggingPrefix
