. ./../../scripts/functions.ps1

D "Starting to launch the server, ui test harness, and deploy subscriptions to event grid." "Run And Test"

$location = Get-Location

$webApiJob = Start-Job -Name "rt-ImagesApi" -ScriptBlock {
    $loggingPrefix = "Run Images API"

    $systemName = $Env:systemName

    Set-Location $args[0]

    . ./../../scripts/functions.ps1

    $location = "../src/ContentReactor.Images/ContentReactor.Images.API"
    
    Set-Location $location
    
    D "Running Images API" $loggingPrefix
    
    func host start --useHttps -p 7075
} -ArgumentList @($location)

$webWorkerJob = Start-Job -Name "rt-ImagesWorker" -ScriptBlock {
    $loggingPrefix = "Run Images Worker"

    $systemName = $Env:systemName

    Set-Location $args[0]

    . ./../../scripts/functions.ps1

    $location = "../src/ContentReactor.Images/ContentReactor.Images.WorkerApi"
    
    Set-Location $location
    
    D "Running Images Worker" $loggingPrefix
    
    func host start --useHttps -p 7076
} -ArgumentList @($location)

$setupLocalTunnel = Start-Job -Name "rt-ImagesWorkerTunnel" -ScriptBlock {
    $loggingPrefix = "Setup Images Worker Tunnel"

    Set-Location $args[0]

    . ./../../scripts/functions.ps1
    
    D "Tunneling to Images Worker" $loggingPrefix
    
    ngrok http https://localhost:7076 -host-header=rewrite
} -ArgumentList @($location)

$apiTestJob = Start-Job -Name "rt-ImagesTestE2E" -ScriptBlock {
    $loggingPrefix = "Images Test E2E"

    Set-Location $args[0]

    . ./../../scripts/functions.ps1

    $location = "../src/ContentReactor.Images/ContentReactor.Images.Tests.E2E"
    
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
                $_.config.addr -like "https://localhost:7076" -and $_.proto -eq "https"
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