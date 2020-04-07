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

$loggingPrefix = "$namePrefix $microserviceName Test Unit"

$currentDirectory = Get-Location

if ($continuous) {
    dotnet watch --project ./../src/$solutionName.$microserviceName/$solutionName.$microserviceName.Tests/$solutionName.$microserviceName.Tests.csproj test --filter TestCategory!=E2E
}
else {
    Set-Location "$PSSCriptRoot/../"

    $directoryStart = Get-Location
    
    Set-Location "$directoryStart/src/$solutionName.$microserviceName/$solutionName.$microserviceName.Tests"
    $command = "dotnet test --logger ""trx;logFileName=testResults.trx"" --filter TestCategory!=E2E"
    $result = ExecuteCommand $command $loggingPrefix "Running the unit tests."
    if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
        $result
    }
    D "Finished running the unit tests." $loggingPrefix
}
Set-Location $currentDirectory