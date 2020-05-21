function Deploy-EdenServiceInfrastructure
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
        [String]$tenantId,
        [Parameter(Mandatory=$true)]  
        [String]$region,
        [Parameter(Mandatory=$true)]  
        [String]$deploymentParameters
    )

    $location = Get-Location

    $loggingPrefix = "$systemName $serviceName Deploy Infrastructure"

    $resourceGroupName = "$systemName-$serviceName".ToLower()
    $deploymentFile = "$location/$serviceName/templates/microservice.json"

    D "Deploying the microservice infrastructure." $loggingPrefix

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

    $command = "az group create -n $resourceGroupName -l $region"
    $result = ExecuteCommand $command $loggingPrefix "Creating the resource group."
    Write-Verbose $result

    $command = "az group deployment create -g $resourceGroupName --template-file $deploymentFile --parameters $deploymentParameters --mode Complete"
    $result = ExecuteCommand $command $loggingPrefix "Deploying the infrastructure."
    Write-Verbose $result

    D "Executing post deployment actions." $loggingPrefix

    Set-Location "$location/$serviceName/"
    ./eden-post-deploy.ps1

    D "Finished executing post deployment actions." $loggingPrefix

    D "Deployed the microservice infrastructure." $loggingPrefix
    Set-Location $currentDirectory
}