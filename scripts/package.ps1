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

$namePrefix = $Env:namePrefix
$solutionName = $Env:solutionName
$microserviceName = $Env:microserviceName
$apiPort = $Env:apiPort
$workerPort = $Env:workerPort

$loggingPrefix = "$namePrefix $microserviceName Package"

Set-Location "$PSSCriptRoot/../"

$directoryStart = Get-Location

D "Packaging the $microserviceName microservice." $loggingPrefix

Set-Location "$directoryStart/$microserviceName/src/$solutionName.$microserviceName/$solutionName.$microserviceName.Api"
$result = ExecuteCommand "dotnet publish -c Release -o $directoryStart/.dist/api" $loggingPrefix "Publishing the api application."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

Set-Location "$directoryStart/$microserviceName/src/$solutionName.$microserviceName/$solutionName.$microserviceName.WorkerApi"
$result = ExecuteCommand "dotnet publish -c Release -o $directoryStart/.dist/worker" $loggingPrefix "Publishing the worker application."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

$apiPath =  "$directoryStart/$microserviceName/.dist/api/**"
$apiDestination = "$directoryStart/$microserviceName/.dist/$solutionName.$microserviceName.Api.zip"
$result = ExecuteCommand "Remove-Item -Path $apiDestination -Recurse -Force -ErrorAction Ignore" $loggingPrefix "Removing the API package."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

$result = ExecuteCommand "Compress-Archive -Path $apiPath -DestinationPath $apiDestination" $loggingPrefix "Creating the API package."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

$workerPath =  "$directoryStart/$microserviceName/.dist/worker/**"
$workerDestination = "$directoryStart/.dist/$solutionName.$microserviceName.WorkerApi.zip"
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
