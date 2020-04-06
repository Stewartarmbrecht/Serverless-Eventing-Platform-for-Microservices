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
    
    func host start -p 7073
} -ArgumentList @($location)

$webWorkerJob = Start-Job -Name "rt-AudioWorker" -ScriptBlock {
    $loggingPrefix = "Run Audio Worker"

    $namePrefix = $Env:namePrefix

    Set-Location $args[0]

    . ./../../scripts/functions.ps1

    $location = "../src/ContentReactor.Audio/ContentReactor.Audio.WorkerApi"
    
    Set-Location $location
    
    D "Running Audio Worker" $loggingPrefix
    
    func host start -p 7074
} -ArgumentList @($location)

$setupLocalTunnel = Start-Job -Name "rt-AudioWorkerTunnel" -ScriptBlock {
    $loggingPrefix = "Setup Audio Worker Tunnel"

    Set-Location $args[0]

    . ./../../scripts/functions.ps1
    
    D "Tunneling to Audio Worker" $loggingPrefix
    
    ngrok http http://localhost:7074 -host-header=rewrite
} -ArgumentList @($location)

$publicUrl = $null
$healthCheck = $FALSE
$subscribed = $FALSE
$testing = $FALSE

While(Get-Job -State "Running")
{
    if ($null -eq $publicUrl) {
        try {
            D "Calling ngrok API" "Get Tunnel"
            $response = Invoke-RestMethod -URI http://localhost:4040/api/tunnels
            $tunnel = $response.tunnels | Where-Object {
                $_.config.addr -like "http://localhost:7074" -and $_.proto -eq "https"
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
    
    if ($FALSE -eq $healthCheck -and $null -ne $publicUrl) {
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
        ./../deploy/deploy-local-subscriptions.ps1 $publicUrl
        $subscribed = $TRUE
        Set-Location $location
    }

    if($FALSE -eq $testing -and $TRUE -eq $subscribed -and $null -ne $publicUrl -and $TRUE -eq $healthCheck) {
        $e2eTestJob = Start-Job -Name "rt-AudioTesting" -ScriptBlock {
            $loggingPrefix = "E2E Testing"
        
            $namePrefix = $Env:namePrefix
        
            Set-Location $args[0]
        
            . ./../../scripts/functions.ps1
        
            D "Running E2E Tests" $loggingPrefix
            
            dotnet watch --project ./../src/ContentReactor.Audio/ContentReactor.Audio.Services.Tests/ContentReactor.Audio.Services.Tests.csproj test --filter TestCategory=E2E
        } -ArgumentList @($location)
        $testing = $TRUE
        Set-Location $location
    }
    
    $webApiJob | Receive-Job
    $webWorkerJob | Receive-Job
    $setupLocalTunnel | Receive-Job
    if ($e2eTestJob) {
        $e2eTestJob | Receive-Job
    }
    if ($subscribeJob) {
        $subscribeJob | Receive-Job
    }
    Start-Sleep -Seconds 1
}