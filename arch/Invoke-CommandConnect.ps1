function Invoke-CommandConnect
{
    [CmdletBinding()]
    param(
        [EdenEnvConfig]$EdenEnvConfig
    ) 
    $pscredential = New-Object System.Management.Automation.PSCredential( `
        $EdenEnvConfig.ServicePrincipalId, `
        $EdenEnvConfig.ServicePrincipalPassword)
    $result = Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $EdenEnvConfig.TenantId
    if ($VerbosePreference -ne "SilentlyContinue") { 
        $result | Write-Verbose
        return $result 
    }    
}

