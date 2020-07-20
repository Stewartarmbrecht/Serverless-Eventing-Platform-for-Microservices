[CmdletBinding()]
param(
    [ValidateLength(3, 18)]
    [String] $InstanceName,
    [String] $Region, 
    [String] $TenantId, 
    [String] $UserId, 
    [SecureString] $Password, 
    [String] $UniqueDeveloperId,
    [Int] $HealthLocalHostingPort = 7061,
    [Switch] $Check
)
. ./Functions.ps1

if ($InstanceName) {
    $loggingPrefix = "ContentReactor Configuration $InstanceName"
} else {
    $loggingPrefix = "ContentReactor Configuration $Env:InstanceName"
}

if (!$Check) 
{
    Write-EdenBuildInfo "Configuring the environment." $loggingPrefix
}

if ($InstanceName) {
    # [Environment]::SetEnvironmentVariable("InstanceName", $InstanceName, [System.EnvironmentVariableTarget]::Machine)
    $Env:InstanceName = $InstanceName
}
if ($Region) {
    # [Environment]::SetEnvironmentVariable("Region", $Region, "User")
    $Env:Region = $Region
}
if ($UserId) {
    # [Environment]::SetEnvironmentVariable("UserId", $UserId, "User")
    $Env:UserId = $UserId
}
if ($Password) {
    # [Environment]::SetEnvironmentVariable("Password", $Password, "User")
    $Env:Password = ConvertFrom-SecureString -SecureString $Password
}
if ($TenantId) {
    # [Environment]::SetEnvironmentVariable("TenantId", $TenantId, "User")
    $Env:TenantId = $TenantId
}
if ($UniqueDeveloperId) {
    # [Environment]::SetEnvironmentVariable("UniqueDeveloperId", $UniqueDeveloperId, "User")
    $Env:UniqueDeveloperId = $UniqueDeveloperId
}
if ($HealthLocalHostingPort) {
    # [Environment]::SetEnvironmentVariable("HealthLocalHostingPort", $HealthLocalHostingPort, "User")
    $Env:HealthLocalHostingPort = $HealthLocalHostingPort
}

if(!$Env:InstanceName) {
    $Env:InstanceName = Read-Host -Prompt 'Please provide a prefix to add to the beginning of every resources for the instance of the system.  Some resources require globally unique names.  This prefix should guarantee that.'
}
if(!$Env:Region) {
    $Env:Region = Read-Host -Prompt 'Please provide a region to deploy to.  Hint: WestUS2'
}
if(!$Env:UserId) {
    $Env:UserId = Read-Host -Prompt 'Please provide the Application (client) ID for a service principle to use for the deployment.'
}
if(!$Env:Password) {
    $Env:Password = Read-Host -AsSecureString -Prompt 'Please provide the service principal secret (password) to use for the deployment.'
}
if(!$Env:TenantId) {
    $Env:TenantId = Read-Host -Prompt 'Please provide the Directory (tenant) ID for the service principal.'
}
if(!$Env:UniqueDeveloperId) {
    $Env:UniqueDeveloperId = Read-Host -Prompt 'Please provide a unique id to identify subscriptions deployed to the cloud for the local developer.'
}
if(!$Env:HealthLocalHostingPort) {
    $Env:HealthLocalHostingPort = Read-Host -Prompt 'Please provide the port number for the audio api.'
}

if (!$Check)
{
    $loggingPrefix = "ContentReactor Configuration $Env:InstanceName"
    Write-Verbose "Env:InstanceName=$Env:InstanceName"
    Write-Verbose "Env:Region=$Env:Region"
    Write-Verbose "Env:UserId=$Env:UserId"
    Write-Verbose "Env:TenantId=$Env:TenantId"
    Write-Verbose "Env:UniqueDeveloperId=$Env:UniqueDeveloperId"
    Write-Verbose "Env:HealthLocalHostingPort=$Env:HealthLocalHostingPort"
    Write-EdenBuildInfo "Configured the environment." $loggingPrefix
}
