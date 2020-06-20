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
    $currentDirectory = Get-Location

    $solutionName = ($currentDirectory -split '\\')[-2]
    $serviceName = ($currentDirectory -split '\\')[-1]

    if ($InstanceName) {
        $loggingPrefix = "$solutionName $serviceName Configuration $InstanceName"
    } else {
        $loggingPrefix = "$solutionName $serviceName Configuration $([System.Environment]::GetEnvironmentVariable("$solutionName.$serviceName.InstanceName"))"
    }
    
    if ($Clear) 
    {
        [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.InstanceName", $null)
        [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.Region", $null)
        [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.UserId", $null)
        [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.Password", $null)
        [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.TenantId", $null)
        [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.UniqueDeveloperId", $null)
        [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.LocalHostingPort", $null)
        Write-BuildInfo "Cleared the environment variables." $loggingPrefix
        return
    }
    
    if (!$Check) 
    {
        Write-BuildInfo "Configuring the environment." $loggingPrefix
    }
    
    if ($InstanceName) { [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.InstanceName", $InstanceName) }
    if ($Region) { [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.Region", $Region) }
    if ($UserId) { [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.UserId", $UserId) }
    if ($Password) { [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.Password", (ConvertFrom-SecureString -SecureString $Password)) }
    if ($TenantId) { [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.TenantId", $TenantId) }
    if ($UniqueDeveloperId) { [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.UniqueDeveloperId", $UniqueDeveloperId) }
    if ($LocalHostingPort) { [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.LocalHostingPort", $LocalHostingPort) }
    
    if(![System.Environment]::GetEnvironmentVariable("$solutionName.$serviceName.InstanceName")) {
        $instanceName = Read-Host -Prompt 'Please provide a prefix to add to the beginning of every resources for the instance of the system.  Some resources require globally unique names.  This prefix should guarantee that.'
        [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.InstanceName", $instanceName)
    }
    if(![System.Environment]::GetEnvironmentVariable("$solutionName.$serviceName.Region")) {
        $region = Read-Host -Prompt 'Please provide a region to deploy to.  Hint: WestUS2'
        [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.Region", $region)
    }
    if(![System.Environment]::GetEnvironmentVariable("$solutionName.$serviceName.UserId")) {
        $userId = Read-Host -Prompt 'Please provide the Application (client) ID for a service principle to use for the deployment.'
        [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.UserId", $userId)
    }
    if(![System.Environment]::GetEnvironmentVariable("$solutionName.$serviceName.Password")) {
        $password = Read-Host -AsSecureString -Prompt 'Please provide the service principal secret (password) to use for the deployment.'
        $passwordVariable = ConvertFrom-SecureString -SecureString $password
        [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.Password", $passwordVariable)
    }
    if(![System.Environment]::GetEnvironmentVariable("$solutionName.$serviceName.TenantId")) {
        $tenantId = Read-Host -Prompt 'Please provide the Directory (tenant) ID for the service principal.'
        [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.TenantId", $tenantId)
    }
    if(![System.Environment]::GetEnvironmentVariable("$solutionName.$serviceName.UniqueDeveloperId")) {
        $uniqueDeveloperId = Read-Host -Prompt 'Please provide a unique id to identify subscriptions deployed to the cloud for the local developer.'
        [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.UniqueDeveloperId", $uniqueDeveloperId)
    }
    if(![System.Environment]::GetEnvironmentVariable("$solutionName.$serviceName.LocalHostingPort")) {
        $localHostingPort = Read-Host -Prompt 'Please provide the local hosting port number for the service app.'
        [System.Environment]::SetEnvironmentVariable("$solutionName.$serviceName.LocalHostingPort", $localHostingPort)
    }
    
    if (!$Check)
    {
        $loggingPrefix = "$solutionName $serviceName $Env:InstanceName"
        Write-Verbose "Env:$solutionName.$serviceName.InstanceName=$([System.Environment]::GetEnvironmentVariable("$solutionName.$serviceName.InstanceName"))"
        Write-Verbose "Env:$solutionName.$serviceName.Region=$([System.Environment]::GetEnvironmentVariable("$solutionName.$serviceName.Region"))"
        Write-Verbose "Env:$solutionName.$serviceName.UserId=$([System.Environment]::GetEnvironmentVariable("$solutionName.$serviceName.UserId"))"
        Write-Verbose "Env:$solutionName.$serviceName.TenantId=$([System.Environment]::GetEnvironmentVariable("$solutionName.$serviceName.TenantId"))"
        Write-Verbose "Env:$solutionName.$serviceName.UniqueDeveloperId=$([System.Environment]::GetEnvironmentVariable("$solutionName.$serviceName.UniqueDeveloperId"))"
        Write-Verbose "Env:$solutionName.$serviceName.LocalHostingPort=$([System.Environment]::GetEnvironmentVariable("$solutionName.$serviceName.LocalHostingPort"))"
        Write-BuildInfo "Configured the environment." $loggingPrefix
    }    
}
