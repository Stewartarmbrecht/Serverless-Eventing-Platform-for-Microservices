param(  
    [String] $shortCommand,
    [String] $command,
    [Alias("v")]
    [string] $verbosity,
    [String] $bigHugeThesaurusApiKey,
    [string] $userName,
    [string] $password,
    [string] $tenantId,
    [string] $uniqueDeveloperId,
    [string] $systemName,
    [string] $region,
    [string] $solutionName,
    [string] $microserviceName,
    [int] $apiPort,
    [int] $workerPort
)

$currentDirectory = Get-Location

Set-Location "$PSScriptRoot"

$shortCommand = $shortCommand.ToLower()
$command = $command.ToLower()
$build = $command -like "*build*" -or $shortCommand -like "*b*"
$continuoustest = $shortCommand -like "*tc*" -or $command -like "*test-continuous*"
$continuous = $continuoustest
$test = ($command -like "*test*" -or $shortCommand -like "*t*") -and !$continuoustest
$run = $shortCommand -like "*r*" -or $command -like "*run*"
$continuouse2e = $shortCommand -like "*ec*" -or $command -like "*e2e-continuous*"
$continuous = $continuoustest
$e2e = ($command -like "*e2e*" -or $shortCommand -like "*e*") -and !$continuouse2e
$package = $command -like "*package*" -or $shortCommand -like "*k*"
$deployAll = $command -like "*deploy-all*" -or $shortCommand -like "*dl*"
$deployInfra = $command -like "*deploy-infrastructure" -or $shortCommand -like "*di*"
$deployApps = $command -like "*deploy-apps*" -or $shortCommand -like "*da*"
$deploySubs = $command -like "*deploy-subscriptions*" -or $shortCommand -like "*ds*"
$pipeline = $command -like "*pipeline*" -or $shortCommand -like "*p*"

if($continuoustest -and 
    ( $run -or $continuouse2e -or $e2e -or $package -or $deployAll -or $deployInfra -or $deployApps -or $deploySubs -or $pipeline)
) {
   Write-Error "You can not run continuous testing and any downstream commands." 
   exit
}

if($run -and 
    ( $continuouse2e -or $e2e -or $package -or $deployAll -or $deployInfra -or $deployApps -or $deploySubs -or $pipeline)
) {
   Write-Error "You can not issue the run command and any downstream commands." 
   exit
}

if($continuouse2e -and 
    ( $package -or $deployAll -or $deployInfra -or $deployApps -or $deploySubs -or $pipeline)
) {
   Write-Error "You can not issue the e2e continuous command and any downstream commands." 
   exit
}

if ($command -eq "configure" -or $shortCommand -eq "config") {
    ./configure-env.ps1 `
        -namePrefix $systemName `
        -region $region `
        -solutionName $solutionName `
        -microserviceName $microserviceName `
        -apiPort $apiPort `
        -workerPort $workerPort `
        -bigHugeThesaurusApiKey $bigHugeThesaurusApiKey, `
        -userName $userName `
        -password $password  `
        -tenantId $tenantId `
        -uniqueDeveloperId $uniqueDeveloperId `
}

if ($pipeline) {
    ./pipeline.ps1 -v $verbosity
    exit
}
if ($build) {
    ./build.ps1 -v $verbosity
}
if ($test) {
    ./test-unit.ps1 -v $verbosity
}
if ($continuoustest) {
    ./test-unit.ps1 -v $verbosity -c $TRUE
}
if ($run) {
    ./run.ps1 -v $verbosity
}
if ($e2e) {
    ./run.ps1 -t $TRUE -v $verbosity
}
if ($continuouse2e) {
    ./run.ps1 -t $TRUE -c $TRUE -v $verbosity -c $TRUE
}
if ($package) {
    ./package.ps1 -v $verbosity
}
if ($deployInfra -or $deployAll) {
    ./deploy-infrastructure.ps1 -v $verbosity
}
if ($deployApps -or $deployAll) {
    ./deploy-apps.ps1 -v $verbosity
}
if ($deploySubs -or $deployAll) {
    ./deploy-subscriptions.ps1 -v $verbosity
}

Set-Location $currentDirectory