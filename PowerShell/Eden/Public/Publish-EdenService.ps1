function Publish-EdenService {
    [CmdletBinding()]
    param(  
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig -Check
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Publish"

        Write-EdenBuildInfo "Publishing the service." $loggingPrefix

        Invoke-EdenCommand "Publish-Service" $edenEnvConfig $loggingPrefix
        
        Write-EdenBuildInfo "Finished publishing the service." $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error publishing the service. Message: '$($_.Exception.Message)'" $loggingPrefix
    }    
}
New-Alias `
    -Name e-dp `
    -Value Publish-EdenService
