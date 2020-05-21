function Deploy-EdenService
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]  
        [String]$serviceName,
        [Parameter(Mandatory=$true)]  
        [String]$solutionName,
        [Parameter(Mandatory=$true)]  
        [String]$systemName
    )

    $loggingPrefix = "$systemName $serviceName Deploy Microservice"
    
    $currentDirectory = Get-Location
        
    D "Deploying the microservice." $loggingPrefix
    
    Deploy-EdenServiceInfrastructure
    
    ./deploy-apps.ps1 -v $verbosity
    
    ./deploy-subscriptions.ps1 -v $verbosity
    
    D "Deployed the microservice." $loggingPrefix
    
    Set-Location $currentDirectory
}
