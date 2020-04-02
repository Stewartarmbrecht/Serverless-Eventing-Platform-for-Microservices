param(  
    [Alias("v")]
    [String]$verbosity
)
$microserviceName = "Audio"
$loggingPrefix = "$microserviceName Test"

$currentDirectory = Get-Location

Set-Location "$PSSCriptRoot/../"

. ./../scripts/functions.ps1

$directoryStart = Get-Location

Set-Location "$directoryStart/src/ContentReactor.$microserviceName"
$result = ExecuteCommand "dotnet build" $loggingPrefix "Building the solution."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

Set-Location "$directoryStart/src/ContentReactor.$microserviceName/ContentReactor.$microserviceName.Services.Tests"
$result = ExecuteCommand "dotnet test --logger ""trx;logFileName=testResults.trx"" --filter TestCategory!=E2E" $loggingPrefix "Testing the solution."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

Set-Location $currentDirectory