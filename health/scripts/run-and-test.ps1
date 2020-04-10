. ./../../scripts/functions.ps1

D "Starting to launch the server, ui test harness, and deploy subscriptions to event grid." "Run And Test"

$location = Get-Location

$webApiJob = Start-Job -Name "rt-HealthApi" -ScriptBlock {
    $loggingPrefix = "Run Health API"

    $systemName = $Env:systemName

    Set-Location $args[0]

    . ./../../scripts/functions.ps1

    $location = "../src/ContentReactor.Health/ContentReactor.Health.API"
    
    Set-Location $location
    
    D "Running Health API" $loggingPrefix
    
    func host start --useHttps -p 7001
} -ArgumentList @($location)

$apiTestJob = Start-Job -Name "rt-HealthTestE2E" -ScriptBlock {
    $loggingPrefix = "Health Test E2E"

    Set-Location $args[0]

    . ./../../scripts/functions.ps1

    $location = "../src/ContentReactor.Health/ContentReactor.Health.Tests.E2E"
    
    Set-Location $location
    
    D "Launching Cypress API Tests" $loggingPrefix
    
    npx cypress open
} -ArgumentList @($location)

While(Get-Job -State "Running")
{
    $webApiJob | Receive-Job
    $apiTestJob | Receive-Job
    Start-Sleep -Seconds 1
}