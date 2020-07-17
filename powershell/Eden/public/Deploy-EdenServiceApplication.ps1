function Deploy-EdenServiceApplication {
    [CmdletBinding()]
    param()
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig -Check
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Deploy Application $($edenEnvConfig.EnvironmentName)"

        Write-BuildInfo "Deploying the application." $loggingPrefix

        Write-BuildInfo "Connecting to the hosting environment." $loggingPrefix

        Invoke-EdenCommand "Connect-ServiceHostingEnvironment" $edenEnvConfig $loggingPrefix
        
        Write-BuildInfo "Connected to the hosting environment." $loggingPrefix

        Write-BuildInfo "Deploying the service application to staging." $loggingPrefix

        Invoke-EdenCommand "Deploy-ServiceAppStaging" $edenEnvConfig $loggingPrefix
        
        Write-BuildInfo "Finished deploying the service application to staging." $loggingPrefix

        Write-BuildInfo "Testing the staging instance of the service application." $loggingPrefix

        Invoke-EdenCommand "Test-ServiceAppStaging" $edenEnvConfig $loggingPrefix
        
        Write-BuildInfo "Finished testing the staging instance of the service application." $loggingPrefix

        Write-BuildInfo "Swapping the staging instance of the service application with the production instance." $loggingPrefix

        Invoke-EdenCommand "Invoke-ServiceStagingSwap" $edenEnvConfig $loggingPrefix
        
        Write-BuildInfo "Finished swapping the staging instance of the service application with the production instance." $loggingPrefix

        Write-BuildInfo "Finished deploying the applications." $loggingPrefix
    }
    catch 
    {
        Write-BuildError "Error deploying the service application. Message: '$($_.Exception.Message)'" $loggingPrefix
        throw $_
    }    
}
