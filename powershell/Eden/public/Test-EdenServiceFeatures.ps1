function Test-EdenServiceFeatures
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [Switch]$Continuous,
        [Parameter()]
        [switch]$RunAutomatedTests,
        [Parameter()]
        [switch]$RunAutomatedTestsContinuously
    )
    
    try {
    
        $edenEnvConfig = Get-EdenEnvConfig -Check
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Run $($edenEnvConfig.EnvironmentName)"
    
        Write-BuildInfo "Starting local service." $loggingPrefix
    
        $serviceJob = Start-ThreadJob -Name "cj-StartLocalService" -ScriptBlock {
            $VerbosePreference = $args[1]
            Invoke-CommandStartLocalService -EdenEnvConfig $args[0]
        } -ArgumentList @($edenEnvConfig, $VerbosePreference)

        Write-BuildInfo "Starting tunnel to local service." $loggingPrefix
    
        $tunnelJob = Start-ThreadJob -Name "cj-StartLocalTunnel" -ScriptBlock {
            $VerbosePreference = $args[1]
            Invoke-CommandStartLocalTunnel -EdenEnvConfig $args[0]
        } -ArgumentList @($edenEnvConfig, $VerbosePreference)

        $healthCheck = $false

        While($serviceJob.State -eq "Running" `
            -and $tunnelJob.State -eq "Running" `
            -and $healthCheck -eq $false)
        {
            Write-BuildInfo "Performing service health check." $loggingPrefix
    
            $healthCheck = Invoke-CommandCheckLocalServiceHealth -EdenEnvConfig $edenEnvConfig

            Write-BuildInfo "Service health check result: '$healthCheck'" $loggingPrefix

            Get-Job | Receive-Job | Write-Verbose

            if (!$healthCheck) {
                Start-Sleep 1
            }
        }
    
        Write-BuildInfo "Deploying event subscriptions for local service." $loggingPrefix

        Get-Job | Receive-Job | Write-Verbose
    
        if (Get-Job -State "Failed") 
        {
            throw "One of the jobs failed."
        }
    
        Set-Location $currentDirectory
    } 
    catch 
    {
        Write-BuildError "Stopping and removing jobs due to exception. Message: '$($_.Exception.Message)'" $loggingPrefix
        Stop-Job rt-*
        Remove-Job rt-*
        Write-BuildError "Stopped." $loggingPrefix
        throw $_
    }
}
