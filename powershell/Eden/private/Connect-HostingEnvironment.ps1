function Connect-HostingEnvironment {
    [CmdletBinding()]
    param(
        [string] $LoggingPrefix
    )

    try {
        [EdenEnvConfig] $envConfig = Get-EdenEnvConfig

        Write-BuildInfo "Connecting to the '$($envConfig.EnvironmentName)' environment in the '$($envConfig.TenantId)' tenant as '$($envConfig.UserId)'" $LoggingPrefix

        Invoke-CommandConnect -UserId $envConfig.UserId -Password $envConfig.Password -Tenant $envConfig.TenantId
        
    }
    catch
    {
        Write-BuildError "Experienced an error connecting to the hosting environment." $LoggingPrefix
        Write-BuildError "Error message: '$($_.Exception.Message)'" $LoggingPrefix
        throw $_
    }
}