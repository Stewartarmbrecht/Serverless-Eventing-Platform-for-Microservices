function Deploy-EdenServiceInfrastructure {
    [CmdletBinding()]
    param()
    
    try {
        $solutionName = Get-SolutionName
        $serviceName = Get-ServiceName
        
        Set-EdenServiceEnvVariables -Check
    
        $instanceName = Get-EnvironmentVariable "$solutionName.$serviceName.InstanceName"
        $region = Get-EnvironmentVariable "$solutionName.$serviceName.Region"
    
        $loggingPrefix = "$solutionName $serviceName Deploy Infrastructure $instanceName"
    
        $resourceGroupName = "$instanceName-$serviceName".ToLower()
        $deploymentFile = "./Infrastructure/Infrastructure.json"
    
        Write-BuildInfo "Deploying the service infrastructure." $loggingPrefix
    
        Connect-AzureServicePrincipal $loggingPrefix
    
        Write-BuildInfo "Creating the resource group: $resourceGroupName." $loggingPrefix
        New-AzResourceGroup -Name $resourceGroupName -Location $region -Force | Write-Verbose
    
        Write-BuildInfo "Executing the deployment using: $deploymentFile." $loggingPrefix
        New-AzResourceGroupDeployment `
            -ResourceGroupName $resourceGroupName `
            -TemplateFile $deploymentFile `
            -TemplateParameterObject @{ InstanceName = $instanceName } | Write-Verbose
    
        Write-BuildInfo "Deployed the service infrastructure." $loggingPrefix
    }
    catch {
        Write-BuildError "Error deploying the service infrastructure. Message: '$($_.Exception.Message)'" $loggingPrefix
        throw $_
    }    
}
