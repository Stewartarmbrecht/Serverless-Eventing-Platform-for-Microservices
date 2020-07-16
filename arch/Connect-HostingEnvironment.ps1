function Connect-HostingEnvironment {
    [CmdletBinding()]
    param(
        [string] $LoggingPrefix
    )

    try {
        [EdenEnvConfig] $envConfig = Get-EdenEnvConfig

        Write-BuildInfo "Connecting to the '$($envConfig.EnvironmentName)' environment in the '$($envConfig.TenantId)' tenant as '$($envConfig.ServicePrincipalId)'" $LoggingPrefix

        Invoke-CommandConnect -EdenEnvConfig $envConfig
        
    }
    catch
    {
        Write-BuildError "Experienced an error connecting to the hosting environment." $LoggingPrefix
        Write-BuildError "Error message: '$($_.Exception.Message)'" $LoggingPrefix
        throw $_
    }
}