function Deploy-EdenServiceApps
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]  
        [String]$serviceName,
        [Parameter(Mandatory=$true)]  
        [String]$systemName,
        [Parameter(Mandatory=$true)]  
        [String]$userName,
        [Parameter(Mandatory=$true)]  
        [SecureString]$password,
        [Parameter(Mandatory=$true)]  
        [String]$tenantId
    )

    $location = Get-Location

    $loggingPrefix = "$systemName $serviceName Deploy Apps"
    
    D "Deploying the applications." $loggingPrefix
    
    $resourceGroupName = "$systemName-$serviceName".ToLower()
    $apiName = "$systemName-$serviceName-api".ToLower()
    $apiFilePath = "$location/$serviceName/.dist/api.zip"
    $workerName = "$systemName-$serviceName-worker".ToLower()
    $workerFilePath = "$location/$serviceName/.dist/worker.zip"
    
    $old_ErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    
    # https://github.com/Microsoft/azure-pipelines-agent/issues/1816
    $command = "az"
    $result = ExecuteCommand $command $loggingPrefix "Executing first AZ call to get around Task bug."
    if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
        $result
    }
    
    $ErrorActionPreference = $old_ErrorActionPreference 
    
    $command = "az login --service-principal --username $userName --password $(ConvertFrom-SecureString $password) --tenant $tenantId"
    $result = ExecuteCommand $command $loggingPrefix "Logging in to the Azure CLI."
    if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
        $result
    }
    
    $old_ErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    
    $command = "az webapp deployment source config-zip --resource-group $resourceGroupName --name $apiName --src $apiFilePath"
    $result = ExecuteCommand $command $loggingPrefix "Deploying the API application."
    if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
        $result
    }
    
    $command = "az webapp deployment source config-zip --resource-group $resourceGroupName --name $workerName --src $workerFilePath"
    $result = ExecuteCommand $command $loggingPrefix "Deploying the worker application."
    if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
        $result
    }
    
    $ErrorActionPreference = $old_ErrorActionPreference 
    D "Finished deploying the applications." $loggingPrefix
}
