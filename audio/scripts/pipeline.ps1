param(  
    [Alias("v")]
    [String] $verbosity
)
. ./../../scripts/functions.ps1

./configure-env.ps1

$namePrefix = $Env:namePrefix
$solutionName = $Env:solutionName
$microserviceName = $Env:microserviceName

$loggingPrefix = "$namePrefix $microserviceName Pipeline Microservice"

$currentDirectory = Get-Location

Set-Location "$PSSCriptRoot"

D "Running the full pipeline for the microservice." $loggingPrefix

./build.ps1 -v $verbosity
./test-unit.ps1 -v $verbosity
./test-e2e.ps1 -v $verbosity
./package.ps1 -v $verbosity
./deploy.ps1 -v $verbosity

D "Finished the full pipeline for the microservice." $loggingPrefix