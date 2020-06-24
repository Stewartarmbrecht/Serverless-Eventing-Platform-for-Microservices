function Set-EdenServiceEnvVariables
{
    [CmdletBinding()]
    param(
        [ValidateLength(3, 18)]
        [String] $InstanceName,
        [String] $Region, 
        [String] $TenantId, 
        [String] $UserId, 
        [SecureString] $Password, 
        [String] $UniqueDeveloperId,
        [Int] $LocalHostingPort,
        [Switch] $Check,
        [Switch] $Clear
        
    )
    $solutionName = Get-SolutionName
    $serviceName = Get-ServiceName

    if ($InstanceName) {
        $loggingPrefix = "$solutionName $serviceName Configuration $InstanceName"
    } else {
        $loggingPrefix = "$solutionName $serviceName Configuration $(Get-EnvironmentVariable "$solutionName.$serviceName.InstanceName")"
    }
    
    if ($Clear) 
    {
        Set-EnvironmentVariable "$solutionName.$serviceName.InstanceName" $null
        Set-EnvironmentVariable "$solutionName.$serviceName.Region" $null
        Set-EnvironmentVariable "$solutionName.$serviceName.UserId" $null
        Set-EnvironmentVariable "$solutionName.$serviceName.Password" $null
        Set-EnvironmentVariable "$solutionName.$serviceName.TenantId" $null
        Set-EnvironmentVariable "$solutionName.$serviceName.UniqueDeveloperId" $null
        Set-EnvironmentVariable "$solutionName.$serviceName.LocalHostingPort" $null
        Write-BuildInfo "Cleared the environment variables." $loggingPrefix
        return
    }
    
    if (!$Check) 
    {
        Write-BuildInfo "Configuring the environment." $loggingPrefix
    }
    
    if ($InstanceName) { Set-EnvironmentVariable "$solutionName.$serviceName.InstanceName" $InstanceName }
    if ($Region) { Set-EnvironmentVariable "$solutionName.$serviceName.Region" $Region }
    if ($UserId) { Set-EnvironmentVariable "$solutionName.$serviceName.UserId" $UserId }
    if ($Password) { Set-EnvironmentVariable "$solutionName.$serviceName.Password" (ConvertFrom-SecureString -SecureString $Password) }
    if ($TenantId) { Set-EnvironmentVariable "$solutionName.$serviceName.TenantId" $TenantId }
    if ($UniqueDeveloperId) { Set-EnvironmentVariable "$solutionName.$serviceName.UniqueDeveloperId" $UniqueDeveloperId }
    if ($LocalHostingPort) { Set-EnvironmentVariable "$solutionName.$serviceName.LocalHostingPort" $LocalHostingPort }
    
    if(!(Get-EnvironmentVariable "$solutionName.$serviceName.InstanceName")) {
        $instanceName = Read-Host -Prompt 'Please provide a prefix to add to the beginning of every resources for the instance of the system.  Some resources require globally unique names.  This prefix should guarantee that.'
        Set-EnvironmentVariable "$solutionName.$serviceName.InstanceName" $instanceName
    }
    if(!(Get-EnvironmentVariable "$solutionName.$serviceName.Region")) {
        $region = Read-Host -Prompt 'Please provide a region to deploy to.  Hint: WestUS2'
        Set-EnvironmentVariable "$solutionName.$serviceName.Region" $region
    }
    if(!(Get-EnvironmentVariable "$solutionName.$serviceName.UserId")) {
        $userId = Read-Host -Prompt 'Please provide the Application (client) ID for a service principle to use for the deployment.'
        Set-EnvironmentVariable "$solutionName.$serviceName.UserId" $userId
    }
    if(!(Get-EnvironmentVariable "$solutionName.$serviceName.Password")) {
        $password = Read-Host -AsSecureString -Prompt 'Please provide the service principal secret (password) to use for the deployment.'
        $passwordVariable = ConvertFrom-SecureString -SecureString $password
        Set-EnvironmentVariable "$solutionName.$serviceName.Password" $passwordVariable
    }
    if(!(Get-EnvironmentVariable "$solutionName.$serviceName.TenantId")) {
        $tenantId = Read-Host -Prompt 'Please provide the Directory (tenant) ID for the service principal.'
        Set-EnvironmentVariable "$solutionName.$serviceName.TenantId" $tenantId
    }
    if(!(Get-EnvironmentVariable "$solutionName.$serviceName.UniqueDeveloperId")) {
        $uniqueDeveloperId = Read-Host -Prompt 'Please provide a unique id to identify subscriptions deployed to the cloud for the local developer.'
        Set-EnvironmentVariable "$solutionName.$serviceName.UniqueDeveloperId" $uniqueDeveloperId
    }
    if(!(Get-EnvironmentVariable "$solutionName.$serviceName.LocalHostingPort")) {
        $localHostingPort = Read-Host -Prompt 'Please provide the local hosting port number for the service app.'
        Set-EnvironmentVariable "$solutionName.$serviceName.LocalHostingPort" $localHostingPort
    }
    
    if (!$Check)
    {
        Write-Verbose "Env:$solutionName.$serviceName.InstanceName=$(Get-EnvironmentVariable "$solutionName.$serviceName.InstanceName")"
        Write-Verbose "Env:$solutionName.$serviceName.Region=$(Get-EnvironmentVariable "$solutionName.$serviceName.Region")"
        Write-Verbose "Env:$solutionName.$serviceName.UserId=$(Get-EnvironmentVariable "$solutionName.$serviceName.UserId")"
        Write-Verbose "Env:$solutionName.$serviceName.TenantId=$(Get-EnvironmentVariable "$solutionName.$serviceName.TenantId")"
        Write-Verbose "Env:$solutionName.$serviceName.UniqueDeveloperId=$(Get-EnvironmentVariable "$solutionName.$serviceName.UniqueDeveloperId")"
        Write-Verbose "Env:$solutionName.$serviceName.LocalHostingPort=$(Get-EnvironmentVariable "$solutionName.$serviceName.LocalHostingPort")"
        Write-BuildInfo "Configured the environment." $loggingPrefix
    }    
}
