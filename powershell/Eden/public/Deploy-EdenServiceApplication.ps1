function Deploy-EdenServiceApplication {
    [CmdletBinding()]
    param()
    
    try {
        $solutionName = Get-SolutionName
        $serviceName = Get-ServiceName
        
        Set-EdenServiceEnvVariables -Check
    
        $instanceName = Get-EnvironmentVariable "$solutionName.$serviceName.InstanceName"
        $tenantId = Get-EnvironmentVariable "$solutionName.$serviceName.TenantId"
        $region = Get-EnvironmentVariable "$solutionName.$serviceName.Region"
    
        $loggingPrefix = "$solutionName $serviceName Deploy App $instanceName"
    
        Write-BuildInfo "Deploying the applications." $loggingPrefix
    
        Connect-HostingEnvironment $loggingPrefix
    
        $automatedTestJob = Test-Automated `
            -SolutionName $solutionName `
            -ServiceName $serviceName `
            -AutomatedUrl "https://$apiName-staging.azurewebsites.net/api/" `
            -LoggingPrefix $loggingPrefix
        
        While($automatedTestJob.State -eq "Running")
        {
            $automatedTestJob | Receive-Job | Write-Verbose
        }
        
        $automatedTestJob | Receive-Job | Write-Verbose
        
        if ($automatedTestJob.State -eq "Failed") {
            Write-BuildError "The staging end to end testing failed." $loggingPrefix
            Write-BuildError "Exiting deployment." $loggingPrefix
            Get-Job | Remove-Job
            throw "Automated tests failed."
        }
        
        Get-Job | Remove-Job

        Invoke-StagingSwap `
            -InstanceName $instanceName `
            -ServiceName $serviceName `
            -LoggingPrefix $loggingPrefix
    
        Write-BuildInfo "Finished deploying the applications." $loggingPrefix
    }
    catch 
    {
        Get-Job | Stop-Job | Remove-Job
        Set-Location $currentDirectory
        throw $_    
    }    
}
