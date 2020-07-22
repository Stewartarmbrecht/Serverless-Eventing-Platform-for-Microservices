function Install-EdenServiceTools {
    [CmdletBinding()]
    param(  
    )
    
    try {
        $edenEnvConfig = Get-EdenEnvConfig -Check
    
        $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Publish"

        Write-EdenBuildInfo "Installing the service tools." $loggingPrefix

        Invoke-EdenCommand "Install-Tools" $edenEnvConfig $loggingPrefix
        
        Write-EdenBuildInfo "Finished installing the service tools." $loggingPrefix
    }
    catch {
        Write-EdenBuildError "Error installing the service tools. Message: '$($_.Exception.Message)'" $loggingPrefix
        exit 1
    }    
}
