function Deploy-EdenServiceInfrastructure
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]  
        [String]$serviceName,
        [Parameter(Mandatory=$true)]  
        [String]$solutionName,
        [Parameter(Mandatory=$true)]  
        [String]$systemName,
        [Parameter(Mandatory=$true)]  
        [String]$userName,
        [Parameter(Mandatory=$true)]  
        [SecureString]$password,
        [Parameter(Mandatory=$true)]  
        [String]$tenantId,
        [Parameter(Mandatory=$true)]  
        [String]$region,
        [Parameter(Mandatory=$true)]  
        [String]$deploymentParameters
    )

    $location = Get-Location

    $loggingPrefix = "$systemName $serviceName Deploy Subscriptions"

    $deploymentParameters = "uniqueResourcesystemName=$systemName"
    $eventsResourceGroupName = "$systemName-events"
    $eventsSubscriptionDeploymentFile = "$location/$serviceName/templates/eventGridSubscriptions.json".ToLower()
    $eventsSubscriptionParameters="uniqueResourcesystemName=$systemName"

    D "Deploying the microservice subscriptions." $loggingPrefix

    $old_ErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'

    # https://github.com/Microsoft/azure-pipelines-agent/issues/1816
    $command = "az"
    $result = ExecuteCommand $command $loggingPrefix "Executing first AZ call to get around Task bug."
    Write-Verbose $result

    $ErrorActionPreference = $old_ErrorActionPreference 

    $command = "az login --service-principal --username $userName --password $password --tenant $tenantId"
    $result = ExecuteCommand $command $loggingPrefix "Logging in the Azure CLI"
    Write-Verbose $result

    $command = "az group deployment create -g $eventsResourceGroupName --template-file $eventsSubscriptionDeploymentFile --parameters $eventsSubscriptionParameters"
    $result = ExecuteCommand $command $loggingPrefix "Deploying the event grid subscription."
    Write-Verbose $result

    D "Deployed the microservice subscriptions." $loggingPrefix
}