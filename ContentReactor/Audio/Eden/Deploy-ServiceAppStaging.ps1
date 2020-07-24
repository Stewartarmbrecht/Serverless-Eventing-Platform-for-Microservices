[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

Write-Verbose "Location: $(Get-Location)"

$resourceGroupName = "$($EdenEnvConfig.EnvironmentName)-audio".ToLower()
$apiName = "$($EdenEnvConfig.EnvironmentName)-audio".ToLower()
$apiFilePath = "$PSSCriptRoot/../.dist/app.zip"

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

Write-Verbose "Location: $(Get-Location)"

Write-EdenBuildInfo "Deploying the azure functions app using zip from '$apiFilePath' to group '$resourceGroupName', app '$apiName' on the staging slot." $LoggingPrefix
Write-Verbose "Location: $(Get-Location)"
Write-Verbose "Api File Path: $apiFilePath"
$result = Publish-AzWebApp -ResourceGroupName $resourceGroupName -Name $apiName -Slot Staging -ArchivePath $apiFilePath -Force
if ($VerbosePreference -ne 'SilentlyContinue') { $result }