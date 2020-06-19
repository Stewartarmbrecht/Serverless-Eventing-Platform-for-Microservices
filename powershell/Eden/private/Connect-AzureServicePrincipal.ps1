function Connect-AzureServicePrincipal {
    [CmdletBinding()]
    param(
        [string] $loggingPrefix
    )

    $userId = $Env:UserId
    $password = $Env:Password
    $tenantId = $Env:TenantId

    Write-BuildInfo "Connecting to service principal: $userId on tenant: $tenantId" $loggingPrefix
    
    $pswd = ConvertTo-SecureString $password
    $pscredential = New-Object System.Management.Automation.PSCredential($userId, $pswd)
    $result = Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $tenantId | Write-Verbose
    if ($VerbosePreference -ne 'SilentlyContinue') { $result }
}