. ./../../scripts/functions.ps1

D "Starting to launch the server, app, ui test harness, and deploy subscriptions to event grid." "Run And Test"

$location = Get-Location

$webServerJob = Start-Job -Name "rt-WebServer" -ScriptBlock {
    $loggingPrefix = "Run Web Server"

    $systemName = $Env:systemName

    $Env:FUNCTION_API_PROXY_ROOT = "https://$systemName-proxy-api.azurewebsites.net"

    Set-Location $args[0]

    . ./../../scripts/functions.ps1

    Write-Host $args[0]
    
    $location = "../src/ContentReactor.Web/ContentReactor.Web.Server"
    
    Set-Location $location
    
    D "Running Web Server" $loggingPrefix
    
    dotnet run
} -ArgumentList @($location)

$setupLocalTunnel = Start-Job -Name "rt-Tunnel" -ScriptBlock {
    $loggingPrefix = "Setup Tunnel"

    Set-Location $args[0]

    . ./../../scripts/functions.ps1

    Write-Host $args[0]
    
    D "Tunneling to Web Server" $loggingPrefix
    
    ngrok http https://localhost:5001 -host-header=rewrite
} -ArgumentList @($location)

$webAppJob = Start-Job -Name "rt-WebApp" -ScriptBlock {
    $loggingPrefix = "Run Web App"

    Set-Location $args[0]

    . ./../../scripts/functions.ps1

    $location = "../src/ContentReactor.Web/ContentReactor.Web.App"
    
    Set-Location $location
    
    D "Running Web App" $loggingPrefix
    
    ng serve
} -ArgumentList @($location)

$uiTestJob = Start-Job -Name "rt-UITest" -ScriptBlock {
    $loggingPrefix = "Test UI"

    Set-Location $args[0]

    . ./../../scripts/functions.ps1

    $location = "../src/ContentReactor.Web/ContentReactor.Web.Tests.UI"
    
    Set-Location $location
    
    D "Launching Cypress UI Tests" $loggingPrefix
    
    npx cypress open
} -ArgumentList @($location)

$publicUrl = $null
$subscribed = $FALSE

While(Get-Job -State "Running")
{
    if ($publicUrl -eq $null) {
        try {
            D "Calling ngrok API" "Get Tunnel"
            $response = Invoke-RestMethod -URI http://localhost:4040/api/tunnels
            $tunnel = $response.tunnels | Where-Object {
                $_.config.addr -like "https://localhost:5001" -and $_.proto -eq "https"
            } | Select-Object public_url
            $publicUrl = $tunnel.public_url
            if($publicUrl -ne $null) {
                D "Public URL: $publicUrl" "Get Tunnel"
            }
        } catch {
            $message = $_.Message
            D "Failed to get tunnel: $message" "Get Tunnel"
            $publicUrl = $null
        }
    }
    
    if($subscribed -eq $FALSE -and $publicUrl -ne $null) {
        D "Deploying subscriptions to event grid." "Event Subscribe"
        $subscribed = $TRUE
        ./../deploy/deploy-local-subscriptions.ps1 $publicUrl
        Set-Location $location
    }
    
    $webServerJob | Receive-Job
    $setupLocalTunnel | Receive-Job
    $webAppJob | Receive-Job
    $uiTestJob | Receive-Job
    if ($subscribeJob) {
        $subscribeJob | Receive-Job
    }
    Start-Sleep -Seconds 1
}