param(  
    [Alias("v")]
    [String] $verbosity
)
$currentDirectory = Get-Location

Set-Location "$PSSCriptRoot"

. ./functions.ps1

./configure-env.ps1

$systemName = $Env:systemName
$solutionName = $Env:solutionName
$microserviceName = $Env:microserviceName

$loggingPrefix = "$systemName $microserviceName Pipeline Microservice"

D "Running the full pipeline for the microservice." $loggingPrefix

./build.ps1 -v $verbosity
./test-unit.ps1 -v $verbosity
./run.ps1 -t $TRUE -v $verbosity
./package.ps1 -v $verbosity
./deploy.ps1 -v $verbosity

D "Finished the full pipeline for the microservice." $loggingPrefix

Set-Location $currentDirectory