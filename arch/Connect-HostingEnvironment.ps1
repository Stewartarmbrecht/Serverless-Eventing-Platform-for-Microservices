function Connect-HostingEnvironment {
    [CmdletBinding()]
    param(
        [string] $LoggingPrefix
    )

    try {
        [EdenEnvConfig] $envConfig = Get-EdenEnvConfig

        Write-EdenBuildInfo "Connecting to the '$($envConfig.EnvironmentName)' environment in the '$($envConfig.TenantId)' tenant as '$($envConfig.ServicePrincipalId)'" $LoggingPrefix

        Invoke-CommandConnect -EdenEnvConfig $envConfig
        
    }
    catch
    {
        Write-EdenBuildError "Experienced an error connecting to the hosting environment." $LoggingPrefix
        Write-EdenBuildError "Error message: '$($_.Exception.Message)'" $LoggingPrefix
        throw $_
    }
}