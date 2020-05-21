. ./../../scripts/functions.ps1

D "Starting to launch the server, ui test harness, and deploy subscriptions to event grid." "Run And Test"

$location = Get-Location

$webApiJob = Start-Job -Name "rt-TextApi" -ScriptBlock {
    $loggingPrefix = "Run Text API"

    $systemName = $Env:systemName

    Set-Location $args[0]

    . ./../../scripts/functions.ps1

    $location = "../src/ContentReactor.Text/ContentReactor.Text.API"
    
    Set-Location $location
    
    D "Running Text API" $loggingPrefix
    
    func host start --useHttps -p 7077
} -ArgumentList @($location)

$apiTestJob = Start-Job -Name "rt-TextTestE2E" -ScriptBlock {
    $loggingPrefix = "Text Test E2E"

    Set-Location $args[0]

    . ./../../scripts/functions.ps1

    $location = "../src/ContentReactor.Text/ContentReactor.Text.Tests.E2E"
    
    Set-Location $location
    
    D "Launching Cypress API Tests" $loggingPrefix
    
    npx cypress open
} -ArgumentList @($location)

While(Get-Job -State "Running")
{
    $webApiJob | Receive-Job
    $apiTestJob | Receive-Job
    if ($subscribeJob) {
        $subscribeJob | Receive-Job
    }
    Start-Sleep -Seconds 1
}