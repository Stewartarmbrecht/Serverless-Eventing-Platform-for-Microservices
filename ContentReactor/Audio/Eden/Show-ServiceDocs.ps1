[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

Write-EdenBuildInfo "Connecting to azure tenant." $loggingPrefix

$pscredential = New-Object System.Management.Automation.PSCredential($EdenEnvConfig.ServicePrincipalId, (ConvertTo-SecureString $EdenEnvConfig.ServicePrincipalPassword))
Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $EdenEnvConfig.TenantId | Write-Verbose

Write-EdenBuildInfo "Generating link to the services resource group in Azure." $loggingPrefix
Write-Host "" -ForegroundColor Blue
Write-Host "Click: http://localhost:8089/README.md" -ForegroundColor Blue
Write-Host "" -ForegroundColor Blue

markserv README.md -p8089