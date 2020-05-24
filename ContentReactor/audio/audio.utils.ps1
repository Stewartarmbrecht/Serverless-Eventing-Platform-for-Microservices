function Start-FunctionApp
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]  
        [Int32]$port,
        [Parameter(Mandatory=$true)]  
        [String]$loggingPrefix,
        [Parameter(Mandatory=$true)]
        [String]$location
    )

    Write-Build Green "$loggingPrefix Starting job rt-AudioFunction-$port."

    $job = Start-Job -Name "rt-AudioFunction-$port" -ScriptBlock {
        $port = $args[0]
        $loggingPrefix = $args[1]
        $location = $args[2]

        Set-Location $location

        Write-Build Green "$loggingPrefix Launching function app on port $port."
        $old_ErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = 'SilentlyContinue'
        func host start -p $port
        $ErrorActionPreference = $old_ErrorActionPreference 
        Write-Build Green "$loggingPrefix The function app is running."
    } -ArgumentList @($port, $loggingPrefix, $location)

    return $job
}

function Start-LocalTunnel
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]  
        [Int32]$port,
        [Parameter(Mandatory=$true)]  
        [String]$loggingPrefix
    )

    $job = Start-Job -Name "rt-Audio-Tunnel-$port" -ScriptBlock {

        $port = $args[0]
        $loggingPrefix = $args[1]
    
        Write-Build Green "$loggingPrefix Tunneling to the function app on port $port."
        ./ngrok http http://localhost:$port -host-header=rewrite
        Write-Build Green "$loggingPrefix The function app tunnel is up."
    
    } -ArgumentList @($port, $loggingPrefix)

    return $job
}

function Get-PublicUrl
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]  
        [Int32]$port,
        [Parameter(Mandatory=$true)]  
        [String]$loggingPrefix
    )

    try {
        Write-Build Green "$loggingPrefix Calling the ngrok API to get the public url."
        $response = Invoke-RestMethod -URI http://localhost:4040/api/tunnels
        $tunnel = $response.tunnels | Where-Object {
            $_.config.addr -like "http://localhost:$port" -and $_.proto -eq "https"
        } | Select-Object public_url
        [String]$publicUrl = $tunnel.public_url
        if("" -ne $publicUrl) {
            Write-Build Green "$loggingPrefix Found the public URL: '$publicUrl'."
        }
        return $publicUrl
    } catch {
        Write-Build Green "$loggingPrefix Failed to get the public url"
        Write-Build Green $_
        return ""
    }
}

function Invoke-HealthCheck
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]  
        [String]$publicUrl,
        [Parameter(Mandatory=$true)]  
        [String]$loggingPrefix
    )

    try {
        Write-Build Green "$loggingPrefix Checking worker API availability at: $publicUrl/api/healthcheck?userId=developer98765@test.com"
        $response = Invoke-RestMethod -URI "$publicUrl/api/healthcheck?userId=developer98765@test.com"
        $status = $response.status
        if($status -eq 0) {
            Write-Build Green "$loggingPrefix Health check status: $status."
            return $TRUE
        } else {
            return $FALSE
        }
    } catch {
        $message = $_.Message
        Write-Build Green "$loggingPrefix Failed to execute health check: '$message'."
        return $FALSE
    }
}

function Deploy-LocalSubscriptions
{
    [CmdletBinding()]
    param(  
        [Parameter(Mandatory=$true)]  
        [String] $systemName,
        [Parameter(Mandatory=$true)]  
        [String] $userName,
        [Parameter(Mandatory=$true)]  
        [String] $password,
        [Parameter(Mandatory=$true)]  
        [String] $tenantId,
        [Parameter(Mandatory=$true)]  
        [String] $publicUrlToLocalWebServer,
        [Parameter(Mandatory=$true)]  
        [String] $uniqueDeveloperId,
        [Parameter(Mandatory=$true)]  
        [String] $loggingPrefix
    )
    
    $eventsResourceGroupName = "$systemName-events"
    
    Write-Build Green "$loggingPrefix Deploying the web server subscriptions." 
    
    Write-Build Green "$loggingPrefix Logging into Azure." 

    az login --service-principal --username $userName --password $password --tenant $tenantId
    
    $expireTime = Get-Date
    $expireTimeUtc = $expireTime.AddHours(1).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

    Write-Build Green "$loggingPrefix Deploying the event grid subscription."
    az group deployment create -g $eventsResourceGroupName --template-file ./templates/eventGridSubscriptions.local.json --parameters uniqueResourcesystemName=$systemName publicUrlToLocalWebServer=$publicUrlToLocalWebServer uniqueDeveloperId=$uniqueDeveloperId expireTimeUtc=$expireTimeUtc

    Write-Build Green "$loggingPrefix Deployed the subscriptions."
}

function Test-EndToEnd
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]  
        [bool]$continuous
    )

    $job = Start-Job -Name "rt-Audio-Testing" -ScriptBlock {
        $continuous = $args[0]
        $loggingPrefix = $args[1]

        if ($continuous)
        {
            Write-Build Green "$loggingPrefix Running E2E tests."
            dotnet watch --project ./tests/ContentReactor.Audio.Tests.csproj test --filter TestCategory=E2E
        }
        else
        {
            Write-Build Green "$loggingPrefix Running E2E tests."
            dotnet test ./tests/ContentReactor.Audio.Tests.csproj --filter TestCategory=E2E
            Write-Build Green "$loggingPrefix Finished running E2E tests."
        }
    } -ArgumentList @($continuous, $loggingPrefix)

    return $job

}

function Start-EdenService
{

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]  
        [String]$systemName,
        [Parameter(Mandatory=$true)]  
        [String]$userName,
        [Parameter(Mandatory=$true)]  
        [String]$password,
        [Parameter(Mandatory=$true)]  
        [String]$tenantId,
        [Parameter(Mandatory=$true)]  
        [String]$uniqueDeveloperId,
        [Parameter(Mandatory=$true)]  
        [Int32]$apiPort,
        [Parameter(Mandatory=$true)]  
        [Int32]$workerPort,
        [Boolean] $test = $FALSE,
        [Boolean] $continuous = $FALSE
    )

    $subscriptions = if($test) {$TRUE} else {$FALSE}

    $loggingPrefix = "$systemName $serviceName Run"

    Write-Build Green "$loggingPrefix Starting jobs."

    Start-FunctionApp -port $apiPort -loggingPrefix $loggingPrefix -location "./api"

    Start-FunctionApp -port $workerPort -loggingPrefix $loggingPrefix -location "./worker"

    if($subscriptions) {
        Start-LocalTunnel -port $workerPort -loggingPrefix $loggingPrefix
    }

    $publicUrl = if($subscriptions) {""} else {"skip"}
    $healthCheck = if($subscriptions) {$FALSE} else {$TRUE}
    $subscribed = if($subscriptions) {$FALSE} else {$TRUE}
    $testing = if($subscriptions) {$FALSE} else {$TRUE}

    # Change the default behavior of CTRL-C so that the script can intercept and use it versus just terminating the script.
    [Console]::TreatControlCAsInput = $True

    While(Get-Job -State "Running")
    {
        if ("" -eq $publicUrl) {
            $publicUrl = Get-PublicUrl -port $workerPort -loggingPrefix $loggingPrefix
        }
        
        if ($FALSE -eq $healthCheck -and "" -ne $publicUrl) {
            Write-Build Green "Why here?"
            Write-Build Green $publicUrl.GetType()
            $healthCheck = Invoke-HealthCheck -publicUrl $publicUrl -loggingPrefix $loggingPrefix
        }
        
        
        if($subscribed -eq $FALSE -and "" -ne $publicUrl -and $TRUE -eq $healthCheck) {
            Write-Build Green "The public url: $publicUrl"
            Deploy-LocalSubscriptions `
                -systemName $systemName `
                -userName $userName `
                -password $password `
                -tenantId $tenantId `
                -publicUrlToLocalWebServer $publicUrl.ToString() `
                -uniqueDeveloperId $uniqueDeveloperId `
                -loggingPrefix $loggingPrefix
            $subscribed = $TRUE
        }

        if($FALSE -eq $testing -and $TRUE -eq $subscribed -and "" -ne $publicUrl -and $TRUE -eq $healthCheck) {
            $e2eTestJob = Test-EndToEnd -continuous $continuous
            $testing = $TRUE
        }

        Get-Job | Receive-Job

        if ($e2eTestJob.State -eq "Completed")
        {
            Write-Build Green "$loggingPrefix Stopping and removing jobs."
            Stop-Job rt-*
            Remove-Job rt-*
            Write-Build Green "$loggingPrefix Stopped."
        }
        # Sleep for 1 second and then flush the key buffer so any previously pressed keys are discarded and the loop can monitor for the use of
        #   CTRL-C. The sleep command ensures the buffer flushes correctly.
        # $Host.UI.RawUI.FlushInputBuffer()
        Start-Sleep -Seconds 1
        # If a key was pressed during the loop execution, check to see if it was CTRL-C (aka "3"), and if so exit the script after clearing
        #   out any running jobs and setting CTRL-C back to normal.
        If ($Host.UI.RawUI.KeyAvailable -and ($Key = $Host.UI.RawUI.ReadKey("AllowCtrlC,NoEcho,IncludeKeyUp"))) {
            If ([Int]$Key.Character -eq 3) {
                Write-Warning "CTRL-C was used - Shutting down any running jobs before exiting the script."
                Write-Build Green "$loggingPrefix Stopping and removing jobs."
                Stop-Job rt-*
                Remove-Job rt-*
                Write-Build Green "$loggingPrefix Stopped."
                [Console]::TreatControlCAsInput = $False
            }
            # Flush the key buffer again for the next loop.
            # $Host.UI.RawUI.FlushInputBuffer()
        }
    }
}