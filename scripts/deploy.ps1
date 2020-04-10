param(  
    [Alias("v")]
    [String] $verbosity
)
. ./../../scripts/functions.ps1

./configure-env.ps1

$namePrefix = $Env:namePrefix
$solutionName = $Env:solutionName
$microserviceName = $Env:microserviceName

$loggingPrefix = "$namePrefix $microserviceName Deploy Microservice"

$currentDirectory = Get-Location

Set-Location "$PSScriptRoot"

D "Deploying the microservice." $loggingPrefix

./deploy-infrastructure.ps1 -v $verbosity

./deploy-apps.ps1 -v $verbosity

./deploy-subscriptions.ps1 -v $verbosity

D "Deployed the microservice." $loggingPrefix

Set-Location $currentDirectory