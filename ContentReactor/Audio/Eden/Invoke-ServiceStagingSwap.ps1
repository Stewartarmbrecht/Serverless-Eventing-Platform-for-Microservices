[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

$resourceGroupName = "$($EdenEnvConfig.EnvironmentName)-audio".ToLower()
$apiName = "$($EdenEnvConfig.EnvironmentName)-audio".ToLower()

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

Write-EdenBuildInfo "Switching the '$resourceGroupName/$apiName' azure functions app staging slot with production." $LoggingPrefix
$result = Switch-AzWebAppSlot -SourceSlotName "Staging" -DestinationSlotName "Production" -ResourceGroupName $resourceGroupName -Name $apiName
if ($VerbosePreference -ne 'SilentlyContinue') { $result }