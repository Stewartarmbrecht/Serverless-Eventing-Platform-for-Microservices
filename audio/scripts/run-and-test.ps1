. ./../../scripts/functions.ps1

D "Starting to launch the server, ui test harness, and deploy subscriptions to event grid." "Run And Test"

$location = Get-Location

$webApiJob = Start-Job -Name "rt-AudioApi" -ScriptBlock {
    $loggingPrefix = "Run Audio API"

    $namePrefix = $Env:namePrefix

    Set-Location $args[0]

    . ./../../scripts/functions.ps1

    $location = "../src/ContentReactor.Audio/ContentReactor.Audio.API"
    
    Set-Location $location
    
    D "Running Audio API" $loggingPrefix
    
    func host start --useHttps -p 7073
} -ArgumentList @($location)

$webWorkerJob = Start-Job -Name "rt-AudioWorker" -ScriptBlock {
    $loggingPrefix = "Run Audio Worker"

    $namePrefix = $Env:namePrefix

    Set-Location $args[0]

    . ./../../scripts/functions.ps1

    $location = "../src/ContentReactor.Audio/ContentReactor.Audio.WorkerApi"
    
    Set-Location $location
    
    D "Running Audio Worker" $loggingPrefix
    
    func host start --useHttps -p 7074
} -ArgumentList @($location)

$setupLocalTunnel = Start-Job -Name "rt-AudioWorkerTunnel" -ScriptBlock {
    $loggingPrefix = "Setup Audio Worker Tunnel"

    Set-Location $args[0]

    . ./../../scripts/functions.ps1
    
    D "Tunneling to Audio Worker" $loggingPrefix
    
    ngrok http https://localhost:7074 -host-header=rewrite
} -ArgumentList @($location)

$apiTestJob = Start-Job -Name "rt-AudioTestE2E" -ScriptBlock {
    $loggingPrefix = "Audio Test E2E"

    Set-Location $args[0]

    . ./../../scripts/functions.ps1

    $location = "../src/ContentReactor.Audio/ContentReactor.Audio.Tests.E2E"
    
    Set-Location $location
    
    D "Launching Cypress API Tests" $loggingPrefix
    
    npx cypress open
} -ArgumentList @($location)

$publicUrl = $null
$healthCheck = $FALSE
$subscribed = $FALSE

While(Get-Job -State "Running")
{
    if ($null -eq $publicUrl) {
        try {
            D "Calling ngrok API" "Get Tunnel"
            $response = Invoke-RestMethod -URI http://localhost:4040/api/tunnels
            $tunnel = $response.tunnels | Where-Object {
                $_.config.addr -like "https://localhost:7074" -and $_.proto -eq "https"
            } | Select-Object public_url
            $publicUrl = $tunnel.public_url
            if($null -ne $publicUrl) {
                D "Public URL: $publicUrl" "Get Tunnel"
            }
        } catch {
            $message = $_.Message
            D "Failed to get tunnel: $message" "Get Tunnel"
            $publicUrl = $null
        }
    }
    
    if ($FALSE -eq $healthCheck) {
        try {
            D "Checking worker API availability at: $publicUrl/api/healthcheck?userId=developer98765@test.com" "Worker Health Check"
            $response = Invoke-RestMethod -URI "$publicUrl/api/healthcheck?userId=developer98765@test.com"
            $status = $response.status
            if($status -eq 0) {
                D "Health Check Status: $status" "Worker Health Check"
                $healthCheck = $TRUE
            }
        } catch {
            $message = $_.Message

            D "Failed to execute health check: $message" "Worker Health Check"
            $healthCheck = $FALSE
        }
    }
    
    
    if($subscribed -eq $FALSE -and $null -ne $publicUrl -and $TRUE -eq $healthCheck) {
        D "Deploying subscriptions to event grid." "Event Subscribe"
        $subscribed = $TRUE
        ./../deploy/deploy-local-subscriptions.ps1 $publicUrl
        Set-Location $location
    }
    
    
    $webApiJob | Receive-Job
    $webWorkerJob | Receive-Job
    $setupLocalTunnel | Receive-Job
    $apiTestJob | Receive-Job
    if ($subscribeJob) {
        $subscribeJob | Receive-Job
    }
    Start-Sleep -Seconds 1
}