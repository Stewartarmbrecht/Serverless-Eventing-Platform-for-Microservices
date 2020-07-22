[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)
try {

    # When the function application runs locally it connects to cloud resources (Blob Storage).
    # This script deploys the resources for the service to Azure and then updates the local 
    # function app settings to point to the resouces in the clouds that it needs to run.
    # TODO: Refactor the application so that it can run with local storage.

    Build-EdenService

    Test-EdenServiceCode
    
    Publish-EdenService
    
    Deploy-EdenServiceInfrastructure
    
    Deploy-EdenServiceApplication
    
    $currentDirectory = Get-Location
    
    Set-Location "./Service"

    Write-EdenBuildInfo "Fetching the app settings from azure." $LoggingPrefix
    func azure functionapp fetch-app-settings "$($EdenEnvConfig.EnvironmentName)-audio"

    Write-EdenBuildInfo "Adding the run time setting for 'dotnet'." $LoggingPrefix
    func settings add "FUNCTIONS_WORKER_RUNTIME" "dotnet"

    Write-EdenBuildInfo "Adding the run time port setting for '7071'." $LoggingPrefix
    func settings add "Host.LocalHttpPort" "7071"
    
    Set-Location $currentDirectory        
}
catch {
    Set-Location $currentDirectory
    throw $_
}

