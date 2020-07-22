function Set-EdenEnvConfig
{
    [CmdletBinding()]
    param(
        [String] $SolutionName,
        [String] $ServiceName,
        [ValidateLength(3, 18)]
        [String] $EnvironmentName,
        [String] $Region, 
        [String] $TenantId, 
        [String] $ServicePrincipalId, 
        [SecureString] $ServicePrincipalPassword, 
        [String] $DeveloperId,
        [Switch] $Check,
        [Switch] $Clear,
        [Switch] $Save,
        [String] $Load
        
    )

    if ($Load) {
        [String]$json = Get-Content "./Eden/$Load.json"
        $jsonObject = ConvertFrom-Json $json
        $DeveloperId = $jsonObject.DeveloperId
        $EnvironmentName = $jsonObject.EnvironmentName
        $Region = $jsonObject.Region
        $ServiceName = $jsonObject.ServiceName
        $ServicePrincipalId = $jsonObject.ServicePrincipalId
        $ServicePrincipalPassword = (ConvertTo-SecureString $jsonObject.ServicePrincipalPassword)
        $SolutionName = $jsonObject.SolutionName
        $TenantId = $jsonObject.TenantId
    }
    if (!$SolutionName) {
        $SolutionName = Get-SolutionName
    }
    if (!$ServiceName) {
        $ServiceName = Get-ServiceName
    }

    if ($EnvironmentName) {
        $loggingPrefix = "$SolutionName $ServiceName Configuration $EnvironmentName"
    } else {
        $envName = Get-EnvironmentVariable "$SolutionName.$ServiceName.EnvironmentName"
        if ($envName) {
            $loggingPrefix = "$SolutionName $ServiceName Configuration $envName"
        }
        else {
            $loggingPrefix = "$SolutionName $ServiceName Configuration"
        }
    }
    
    if ($Clear) 
    {
        Set-EnvironmentVariable "$SolutionName.$ServiceName.EnvironmentName" $null
        Set-EnvironmentVariable "$SolutionName.$ServiceName.Region" $null
        Set-EnvironmentVariable "$SolutionName.$ServiceName.ServicePrincipalId" $null
        Set-EnvironmentVariable "$SolutionName.$ServiceName.ServicePrincipalPassword" $null
        Set-EnvironmentVariable "$SolutionName.$ServiceName.TenantId" $null
        Set-EnvironmentVariable "$SolutionName.$ServiceName.DeveloperId" $null
        Write-EdenBuildInfo "Cleared the environment variables." $loggingPrefix
        return
    }
    
    if (!$Check) 
    {
        Write-EdenBuildInfo "Configuring the environment." $loggingPrefix
    }
    
    if ($EnvironmentName) { Set-EnvironmentVariable "$SolutionName.$ServiceName.EnvironmentName" $EnvironmentName }
    if ($Region) { Set-EnvironmentVariable "$SolutionName.$ServiceName.Region" $Region }
    if ($ServicePrincipalId) { Set-EnvironmentVariable "$SolutionName.$ServiceName.ServicePrincipalId" $ServicePrincipalId }
    if ($ServicePrincipalPassword) { Set-EnvironmentVariable "$SolutionName.$ServiceName.ServicePrincipalPassword" (ConvertFrom-SecureString -SecureString $ServicePrincipalPassword) }
    if ($TenantId) { Set-EnvironmentVariable "$SolutionName.$ServiceName.TenantId" $TenantId }
    if ($DeveloperId) { Set-EnvironmentVariable "$SolutionName.$ServiceName.DeveloperId" $DeveloperId }
    
    if(!(Get-EnvironmentVariable "$SolutionName.$ServiceName.EnvironmentName")) {
        $environmentName = Read-Host -Prompt 'Please provide a prefix to add to the beginning of every resources for the instance of the system.  Some resources require globally unique names.  This prefix should guarantee that.'
        Set-EnvironmentVariable "$SolutionName.$ServiceName.EnvironmentName" $environmentName
    }
    if(!(Get-EnvironmentVariable "$SolutionName.$ServiceName.Region")) {
        $region = Read-Host -Prompt 'Please provide a region to deploy to.  Hint: WestUS2'
        Set-EnvironmentVariable "$SolutionName.$ServiceName.Region" $region
    }
    if(!(Get-EnvironmentVariable "$SolutionName.$ServiceName.ServicePrincipalId")) {
        $userId = Read-Host -Prompt 'Please provide the Application (client) ID for a service principle to use for the deployment.'
        Set-EnvironmentVariable "$SolutionName.$ServiceName.ServicePrincipalId" $userId
    }
    if(!(Get-EnvironmentVariable "$SolutionName.$ServiceName.ServicePrincipalPassword")) {
        $password = Read-Host -AsSecureString -Prompt 'Please provide the service principal secret (password) to use for the deployment.'
        $passwordVariable = ConvertFrom-SecureString -SecureString $password
        Set-EnvironmentVariable "$SolutionName.$ServiceName.ServicePrincipalPassword" $passwordVariable
    }
    if(!(Get-EnvironmentVariable "$SolutionName.$ServiceName.TenantId")) {
        $tenantId = Read-Host -Prompt 'Please provide the Directory (tenant) ID for the service principal.'
        Set-EnvironmentVariable "$SolutionName.$ServiceName.TenantId" $tenantId
    }
    if(!(Get-EnvironmentVariable "$SolutionName.$ServiceName.DeveloperId")) {
        $uniqueDeveloperId = Read-Host -Prompt 'Please provide a unique id to identify subscriptions deployed to the cloud for the local developer.'
        Set-EnvironmentVariable "$SolutionName.$ServiceName.DeveloperId" $uniqueDeveloperId
    }
    
    if (!$Check)
    {
        Write-Verbose "Env:$SolutionName.$ServiceName.EnvironmentName=$(Get-EnvironmentVariable "$SolutionName.$ServiceName.EnvironmentName")"
        Write-Verbose "Env:$SolutionName.$ServiceName.Region=$(Get-EnvironmentVariable "$SolutionName.$ServiceName.Region")"
        Write-Verbose "Env:$SolutionName.$ServiceName.ServicePrincipalId=$(Get-EnvironmentVariable "$SolutionName.$ServiceName.ServicePrincipalId")"
        Write-Verbose "Env:$SolutionName.$ServiceName.TenantId=$(Get-EnvironmentVariable "$SolutionName.$ServiceName.TenantId")"
        Write-Verbose "Env:$SolutionName.$ServiceName.DeveloperId=$(Get-EnvironmentVariable "$SolutionName.$ServiceName.DeveloperId")"
        Write-EdenBuildInfo "Configured the environment." $loggingPrefix
    }

    if ($Save) {
        $edenEnvConfig = @{
            EnvironmentName = $EnvironmentName
            DeveloperId = $DeveloperId
            Region = $Region
            ServiceName = $ServiceName
            SolutionName = $SolutionName
            TenantId = $TenantId
            ServicePrincipalId = $ServicePrincipalId
            ServicePrincipalPassword = (ConvertFrom-SecureString -SecureString $ServicePrincipalPassword)    
        }
        $json = ConvertTo-Json $edenEnvConfig
        $json | Out-File "./Eden/$($edenEnvConfig.EnvironmentName).json" -Force
    }
}
