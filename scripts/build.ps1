param(  
    [Alias("c")]
    [Boolean] $continuous,
    [Alias("v")]
    [String] $verbosity
)
$currentDirectory = Get-Location

Set-Location "$PSScriptRoot"

. ./functions.ps1

./configure-env.ps1

$systemName = $Env:systemName
$solutionName = $Env:solutionName
$microserviceName = $Env:microserviceName
$apiPort = $Env:apiPort
$workerPort = $Env:workerPort

$loggingPrefix = "$systemName $microserviceName Build"

$directoryStart = Get-Location

Set-Location "$directoryStart/../$microserviceName"
$result = ExecuteCommand "dotnet build" $loggingPrefix "Building the solution."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

D "Finished building the solution." $loggingPrefix

Set-Location $currentDirectory