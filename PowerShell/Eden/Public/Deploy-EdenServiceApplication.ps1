function Deploy-EdenServiceApplication {
    [CmdletBinding()]
    param()
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig -Check
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Deploy Application $($edenEnvConfig.EnvironmentName)"

        Write-EdenBuildInfo "Deploying the application." $loggingPrefix

        Write-EdenBuildInfo "Deploying the service application to staging." $loggingPrefix

        Invoke-EdenCommand "Deploy-ServiceAppStaging" $edenEnvConfig $loggingPrefix
        
        Write-EdenBuildInfo "Finished deploying the service application to staging." $loggingPrefix

        Write-EdenBuildInfo "Testing the staging instance of the service application." $loggingPrefix

        Invoke-EdenCommand "Test-ServiceFeaturesStaging" $edenEnvConfig $loggingPrefix
        
        Write-EdenBuildInfo "Finished testing the staging instance of the service application." $loggingPrefix

        Write-EdenBuildInfo "Swapping the staging instance of the service application with the production instance." $loggingPrefix

        Invoke-EdenCommand "Invoke-ServiceStagingSwap" $edenEnvConfig $loggingPrefix
        
        Write-EdenBuildInfo "Finished swapping the staging instance of the service application with the production instance." $loggingPrefix

        Write-EdenBuildInfo "Finished deploying the applications." $loggingPrefix
    }
    catch 
    {
        Write-EdenBuildError "Error deploying the service application. Message: '$($_.Exception.Message)'" $loggingPrefix
        exit 1
    }    
}
