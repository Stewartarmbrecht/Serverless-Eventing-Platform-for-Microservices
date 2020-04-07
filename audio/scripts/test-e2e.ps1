param(  
    [Alias("c")]
    [Boolean] $continuous,
    [Alias("v")]
    [String] $verbosity
)
. ./../../scripts/functions.ps1

./configure-env.ps1

$namePrefix = $Env:namePrefix
$solutionName = $Env:solutionName
$microserviceName = $Env:microserviceName
$apiPort = $Env:apiPort
$workerPort = $Env:workerPort

$loggingPrefix = "$namePrefix $microserviceName Test E2E"

D "Start E2E testing." $loggingPrefix

$location = Get-Location

$webApiJob = Start-Job -Name "rt-$microserviceName-Api" -ScriptBlock {
    $microserviceName = $args[1]
    $apiPort = $args[2]
    $verbosity = $args[3]
    $loggingPrefix = $args[4]
    $solutionName = $args[5]

    $namePrefix = $Env:namePrefix

    Set-Location $args[0]

    . ./../../scripts/functions.ps1

    $location = "../src/$solutionName.$microserviceName/$solutionName.$microserviceName.API"
    
    Set-Location $location
    
    if ($verbosity -eq "Normal" -or $verbosity -eq "n")
    {
        D "Launching the API." $loggingPrefix
        func host start -p $apiPort
        D "The API is running." $loggingPrefix
    }
    else
    {
        ExecuteCommand "func host start -p $apiPort" $loggingPrefix "Running the API."
        D "The API is running." $loggingPrefix
    }
} -ArgumentList @($location, $microserviceName, $apiPort, $verbosity, $loggingPrefix, $solutionName)

$webWorkerJob = Start-Job -Name "rt-$microserviceName-Worker" -ScriptBlock {
    $microserviceName = $args[1]
    $workerPort = $args[2]
    $verbosity = $args[3]
    $loggingPrefix = $args[4]
    $solutionName = $args[5]

    Set-Location $args[0]

    . ./../../scripts/functions.ps1

    $location = "../src/$solutionName.$microserviceName/$solutionName.$microserviceName.WorkerApi"
    
    Set-Location $location
    
    if ($verbosity -eq "Normal" -or $verbosity -eq "n")
    {
        D "Launching the worker API." $loggingPrefix
        func host start -p $workerPort
        D "The worker API is running." $loggingPrefix
    }
    else
    {
        ExecuteCommand "func host start -p $workerPort" $loggingPrefix "Running the worker API."
        D "The worker API is running." $loggingPrefix
    }
} -ArgumentList @($location, $microserviceName, $workerPort, $verbosity, $loggingPrefix, $solutionName)

$setupLocalTunnel = Start-Job -Name "rt-$microserviceName-WorkerTunnel" -ScriptBlock {
    $microserviceName = $args[1]
    $workerPort = $args[2]
    $verbosity = $args[3]
    $loggingPrefix = $args[4]
    $solutionName = $args[5]

    Set-Location $args[0]

    . ./../../scripts/functions.ps1    
    
    if ($verbosity -eq "Normal" -or $verbosity -eq "n")
    {
        D "Tunneling to the worker API." $loggingPrefix
        ngrok http http://localhost:$workerPort -host-header=rewrite
        D "The worker API tunnel is up." $loggingPrefix
    }
    else
    {
        ExecuteCommand "ngrok http http://localhost:$workerPort -host-header=rewrite" $loggingPrefix "Tunneling to the worker API."
        D "The worker API tunnel is up." $loggingPrefix
    }
} -ArgumentList @($location, $microserviceName, $workerPort, $verbosity, $loggingPrefix, $solutionName)

$publicUrl = $null
$healthCheck = $FALSE
$subscribed = $FALSE
$testing = $FALSE
$tested = $FALSE

While(Get-Job -State "Running")
{
    if ($null -eq $publicUrl) {
        try {
            D "Calling the ngrok API to get the public url." $loggingPrefix
            $response = Invoke-RestMethod -URI http://localhost:4040/api/tunnels
            $tunnel = $response.tunnels | Where-Object {
                $_.config.addr -like "http://localhost:$workerPort" -and $_.proto -eq "https"
            } | Select-Object public_url
            $publicUrl = $tunnel.public_url
            if($null -ne $publicUrl) {
                D "Found the public URL: '$publicUrl'." $loggingPrefix
            }
        } catch {
            $message = $_.Message
            D "Failed to get the public url: '$message'." $loggingPrefix
            $publicUrl = $null
        }
    }
    
    if ($FALSE -eq $healthCheck -and $null -ne $publicUrl) {
        try {
            D "Checking worker API availability at: $publicUrl/api/healthcheck?userId=developer98765@test.com" $loggingPrefix
            $response = Invoke-RestMethod -URI "$publicUrl/api/healthcheck?userId=developer98765@test.com"
            $status = $response.status
            if($status -eq 0) {
                D "Health check status: $status." $loggingPrefix
                $healthCheck = $TRUE
            }
        } catch {
            $message = $_.Message

            D "Failed to execute health check: '$message'." $loggingPrefix
            $healthCheck = $FALSE
        }
    }
    
    
    if($subscribed -eq $FALSE -and $null -ne $publicUrl -and $TRUE -eq $healthCheck) {
        D "Deploying subscriptions to event grid." $loggingPrefix
        ./deploy-local-subscriptions.ps1 -publicUrlToLocalWebServer $publicUrl -v $verbosity
        $subscribed = $TRUE
        Set-Location $location
    }

    if($FALSE -eq $testing -and $TRUE -eq $subscribed -and $null -ne $publicUrl -and $TRUE -eq $healthCheck) {
        $e2eTestJob = Start-Job -Name "rt-$microserviceName-Testing" -ScriptBlock {
            $microserviceName = $args[1]
            $continuous = $args[2]
            $verbosity = $args[3]
            $loggingPrefix = $args[4]
            $solutionName = $args[5]

            Set-Location $args[0]
        
            . ./../../scripts/functions.ps1
        
            if ($continuous)
            {
                D "Running E2E tests." $loggingPrefix
                dotnet watch --project ./../src/$solutionName.$microserviceName/$solutionName.$microserviceName.Tests/$solutionName.$microserviceName.Tests.csproj test --filter TestCategory=E2E
            }
            else
            {
                Set-Location ./../src/$solutionName.$microserviceName/$solutionName.$microserviceName.Tests/
                if ($verbosity -eq "Normal" -or $verbosity -eq "n")
                {
                    D "Running E2E tests." $loggingPrefix
                    dotnet test --filter TestCategory=E2E
                }
                else
                {
                    ExecuteCommand "dotnet test --filter TestCategory=E2E" $loggingPrefix "Running E2E tests."
                }
                D "Finished running E2E tests." $loggingPrefix
            }
        } -ArgumentList @($location, $microserviceName, $continuous, $verbosity, $loggingPrefix, $solutionName)
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
    if ($e2eTestJob.State -eq "Completed")
    {
        D "Finishing E2E testing by stopping and removing jobs." $loggingPrefix
        Stop-Job rt-*
        Remove-Job rt-*
        D "Finished E2E testing." $loggingPrefix
    }
    Start-Sleep -Seconds 1
}