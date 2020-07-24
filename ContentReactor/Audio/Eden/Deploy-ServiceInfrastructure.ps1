[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

    $resourceGroupName = "$($EdenEnvConfig.EnvironmentName)-audio".ToLower()
    $deploymentFile = "./Infrastructure/Infrastructure.json"

    Write-EdenBuildInfo "Connecting to azure tenant using the following configuration:" $loggingPrefix

    Write-EdenBuildInfo "SolutionName       : $($EdenEnvConfig.SolutionName)" $LoggingPrefix
    Write-EdenBuildInfo "ServiceName        : $($EdenEnvConfig.ServiceName)" $LoggingPrefix
    Write-EdenBuildInfo "EnvironmentName    : $($EdenEnvConfig.EnvironmentName)" $LoggingPrefix
    Write-EdenBuildInfo "Region             : $($EdenEnvConfig.Region)" $LoggingPrefix
    Write-EdenBuildInfo "ServicePrincipalId : $($EdenEnvConfig.ServicePrincipalId)" $LoggingPrefix
    Write-EdenBuildInfo "TenantId           : $($EdenEnvConfig.TenantId)" $LoggingPrefix
    Write-EdenBuildInfo "DeveloperId        : $($EdenEnvConfig.DeveloperId)" $LoggingPrefix

    $pscredential = New-Object System.Management.Automation.PSCredential($EdenEnvConfig.ServicePrincipalId, (ConvertTo-SecureString $EdenEnvConfig.ServicePrincipalPassword))
    Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $EdenEnvConfig.TenantId | Write-Verbose

    Write-EdenBuildInfo "Creating the resource group: $resourceGroupName." $LoggingPrefix
    New-AzResourceGroup -Name $resourceGroupName -Location $EdenEnvConfig.Region -Force | Write-Verbose

    Write-EdenBuildInfo "Executing the deployment using: '$deploymentFile'." $LoggingPrefix
    New-AzResourceGroupDeployment `
        -ResourceGroupName $resourceGroupName `
        -TemplateFile $deploymentFile `
        -EnvironmentName $EdenEnvConfig.EnvironmentName | Write-Verbose
