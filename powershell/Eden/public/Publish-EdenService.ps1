function Publish-EdenService {
    [CmdletBinding()]
    param(  
    )
    
    try {
        $solutionName = Get-SolutionName
        $serviceName = Get-ServiceName
    
        Set-EdenServiceEnvVariables -Check
    
        $loggingPrefix = "$solutionName $serviceName Publish"
        
        Write-BuildInfo "Publishing the service." $loggingPrefix

        Invoke-CommandPublish -SolutionName $solutionName -ServiceName $serviceName
        
        Write-BuildInfo "Finished publishing the service." $loggingPrefix
    }
    catch {
        Write-BuildError "Error publishing the service. Message: '$($_.Exception.Message)'" $loggingPrefix
        throw $_
    }    
}
