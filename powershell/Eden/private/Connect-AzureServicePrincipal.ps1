function Connect-AzureServicePrincipal {
    [CmdletBinding()]
    param(
        [string] $LoggingPrefix
    )

    try {
        
        $solutionName = Get-SolutionName
        $serviceName = Get-ServiceName

        $userId = Get-EnvironmentVariable "$solutionName.$serviceName.UserId"
        $password = Get-EnvironmentVariable "$solutionName.$serviceName.Password"
        $tenantId = Get-EnvironmentVariable "$solutionName.$serviceName.TenantId"
    
        Write-BuildInfo "Connecting to service principal: $userId on tenant: $tenantId" $LoggingPrefix
        
        $pswd = ConvertTo-SecureString $password
        $pscredential = New-Object System.Management.Automation.PSCredential($userId, $pswd)
        $result = Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $tenantId
        if ($VerbosePreference -ne "SilentlyContinue") { 
            $result | Write-Verbose
            return $result 
        }    
    }
    catch
    {
        Write-BuildError "Connecting to the Azure service principal failed." $LoggingPrefix
        $message = $_.ErrorDetails.Message
        Write-BuildError "Error message: $message" $LoggingPrefix
        throw
    }
}