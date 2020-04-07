param(  
    [Alias("c")]
    [Boolean] $continuous,
    [Alias("v")]
    [String] $verbosity
)
. ./../../scripts/functions.ps1

./configure-env.ps1

$namePrefix = $Env:namePrefix
$solutionName = $Env:solutionName
$microserviceName = $Env:microserviceName
$apiPort = $Env:apiPort
$workerPort = $Env:workerPort

$loggingPrefix = "$namePrefix $microserviceName Build"

$currentDirectory = Get-Location

Set-Location "$PSSCriptRoot/../"

$directoryStart = Get-Location

Set-Location "$directoryStart/src/$solutionName.$microserviceName"
$result = ExecuteCommand "dotnet build" $loggingPrefix "Building the solution."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

Set-Location $currentDirectory