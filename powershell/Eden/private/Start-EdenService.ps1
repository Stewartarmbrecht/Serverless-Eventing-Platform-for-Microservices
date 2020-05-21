function Start-EdenService
{

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]  
        [String]$serviceName,
        [Parameter(Mandatory=$true)]  
        [String]$solutionName,
        [Parameter(Mandatory=$true)]  
        [String]$systemName,
        [Parameter(Mandatory=$true)]  
        [String]$userName,
        [Parameter(Mandatory=$true)]  
        [SecureString]$password,
        [Parameter(Mandatory=$true)]  
        [String]$tenantId,
        [Parameter(Mandatory=$true)]  
        [String]$region,
        [Parameter(Mandatory=$true)]  
        [String]$deploymentParameters,
        [Parameter(Mandatory=$true)]  
        [Int32]$apiPort,
        [Int32]$workerPort,
        [Alias("t")]
        [Boolean] $test,
        [Alias("c")]
        [Boolean] $continuous,
        [Alias("s")]
        [Boolean] $subscriptions
    )

    $subscriptions = if($test) {$TRUE} else {$FALSE}

    $location = Get-Location

    $loggingPrefix = "$systemName $serviceName Run"

    D "Starting jobs." $loggingPrefix

    $webApiJob = Start-Job -Name "rt-$serviceName-Api" -ScriptBlock {
        $serviceName = $args[1]
        $apiPort = $args[2]
        $verbosity = $args[3]
        $loggingPrefix = $args[4]

        $systemName = $Env:systemName

        Set-Location $args[0]

        . ./functions.ps1

        $location = "./$serviceName/api"
        
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
    } -ArgumentList @($location, $serviceName, $apiPort, $verbosity, $loggingPrefix)

    $webWorkerJob = Start-Job -Name "rt-$serviceName-Worker" -ScriptBlock {
        $serviceName = $args[1]
        $workerPort = $args[2]
        $verbosity = $args[3]
        $loggingPrefix = $args[4]
        $solutionName = $args[5]

        Set-Location $args[0]

        . ./functions.ps1

        $location = "./../$serviceName/worker"
        
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
    } -ArgumentList @($location, $serviceName, $workerPort, $verbosity, $loggingPrefix, $solutionName)

    $setupLocalTunnel

    if($subscriptions) {
        $setupLocalTunnel = Start-Job -Name "rt-$serviceName-WorkerTunnel" -ScriptBlock {
            $serviceName = $args[1]
            $workerPort = $args[2]
            $verbosity = $args[3]
            $loggingPrefix = $args[4]
            $solutionName = $args[5]
        
            Set-Location $args[0]
        
            . ./functions.ps1    
            
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
        } -ArgumentList @($location, $serviceName, $workerPort, $verbosity, $loggingPrefix, $solutionName)
    }

    $publicUrl = if($subscriptions) {$null} else {"skip"}
    $healthCheck = if($subscriptions) {$FALSE} else {$TRUE}
    $subscribed = if($subscriptions) {$FALSE} else {$TRUE}
    $testing = if($subscriptions) {$FALSE} else {$TRUE}
    $tested = $FALSE

    # Change the default behavior of CTRL-C so that the script can intercept and use it versus just terminating the script.
    [Console]::TreatControlCAsInput = $True

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
            $e2eTestJob = Start-Job -Name "rt-$serviceName-Testing" -ScriptBlock {
                $serviceName = $args[1]
                $continuous = $args[2]
                $verbosity = $args[3]
                $loggingPrefix = $args[4]
                $solutionName = $args[5]

                Set-Location $args[0]
            
                . ./functions.ps1
            
                if ($continuous)
                {
                        D "Running E2E tests." $loggingPrefix
                        dotnet watch --project ./../$serviceName/tests/$solutionName.$serviceName.Tests.csproj test --filter TestCategory=E2E
                }
                else
                {
                    Set-Location ./../$serviceName/tests/
                    if ($verbosity -eq "Normal" -or $verbosity -eq "n")
                    {
                        D "Running E2E tests." $loggingPrefix
                        dotnet test --filter TestCategory=E2E
                    }
                    else
                    {
                        $result = ExecuteCommand "dotnet test --filter TestCategory=E2E" $loggingPrefix "Running E2E tests."
                    }
                    D "Finished running E2E tests." $loggingPrefix
                }
            } -ArgumentList @($location, $serviceName, $continuous, $verbosity, $loggingPrefix, $solutionName)
            $testing = $TRUE
            Set-Location $location
        }

        $webApiJob | Receive-Job
        $webWorkerJob | Receive-Job
        if ($setupLocalTunnel) {
            $setupLocalTunnel | Receive-Job
        }
        if ($e2eTestJob) {
            $e2eTestJob | Receive-Job
        }
        if ($subscribeJob) {
            $subscribeJob | Receive-Job
        }
        if ($e2eTestJob.State -eq "Completed")
        {
            D "Stopping and removing jobs." $loggingPrefix
            Stop-Job rt-*
            Remove-Job rt-*
            D "Stopped." $loggingPrefix
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
                D "Stopping and removing jobs." $loggingPrefix
                Stop-Job rt-*
                Remove-Job rt-*
                D "Stopped." $loggingPrefix
                [Console]::TreatControlCAsInput = $False
                Set-Location $currentDirectory
            }
            # Flush the key buffer again for the next loop.
            # $Host.UI.RawUI.FlushInputBuffer()
        }
    }

    Set-Location $currentDirectory
}