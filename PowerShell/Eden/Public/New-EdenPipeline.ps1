function New-EdenPipeline {
    [CmdletBinding()]
    param(
        [String]$AccountName,
        [String]$ProjectName
    )
    
    try {
        $solutionName = Get-SolutionName
        $serviceName = Get-ServiceName
        
        Set-EdenServiceEnvVariables -Check

        $instanceName = Get-EnvironmentVariable "$solutionName.$serviceName.InstanceName"
        $region = Get-EnvironmentVariable "$solutionName.$serviceName.Region"

        $loggingPrefix = "$solutionName $serviceName Deploy Infrastructure $instanceName"

        $resourceGroupName = "$solutionName-devops".ToLower()
        $deploymentFile = "./../Infrastructure/Infrastructure.json"

        Write-EdenBuildInfo "Deploying the DevOps infrastructure." $loggingPrefix

        Connect-HostingEnvironment $loggingPrefix

        Write-EdenBuildInfo "Creating the resource group: $resourceGroupName." $loggingPrefix
        New-AzResourceGroup -Name $resourceGroupName -Location $region -Force | Write-Verbose

        Write-EdenBuildInfo "Executing the deployment using: $deploymentFile." $loggingPrefix
        New-AzResourceGroupDeployment `
            -ResourceGroupName $resourceGroupName `
            -TemplateFile $deploymentFile `
            -TemplateParameterObject @{ 
                ProjectName = $projectName
                AccountName = $accountName } `
            
            | Write-Verbose

        Write-EdenBuildInfo "Deployed the service infrastructure." $loggingPrefix
        Set-Location $currentDirectory
    }
    catch {
        Set-Location $currentDirectory
    }
}