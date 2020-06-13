[CmdletBinding()]
param(
    [ValidateLength(3, 18)]
    [String] $InstanceName,
    [String] $Region, 
    [String] $UserId, 
    [SecureString] $Password, 
    [String] $TenantId
)

if ($InstanceName) {
    # [Environment]::SetEnvironmentVariable("InstanceName", $InstanceName, [System.EnvironmentVariableTarget]::Machine)
    $Env:InstanceName = $InstanceName
}
if ($Region) {
    # [Environment]::SetEnvironmentVariable("Region", $Region, "User")
    $Env:Region = $Region
}
if ($UserId) {
    # [Environment]::SetEnvironmentVariable("UserName", $UserName, "User")
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

if(!$Env:InstanceName) {
    $Env:InstanceName = Read-Host -Prompt 'Please provide a prefix to add to the beginning of every resources for the instance of the system.  Some resources require globally unique names.  This prefix should guarantee that.'
}
if(!$Env:Region) {
    $Env:Region = Read-Host -Prompt 'Please provide a region to deploy to.  Hint: WestUS2'
}
if(!$Env:UserId) {
    $Env:UserId = Read-Host -Prompt 'Please provide the Application (client) ID for a service principal to use for the deployment.'
}
if(!$Env:Password) {
    $Env:Password = Read-Host -AsSecureString -Prompt 'Please provide the service principal secret (password) to use for the deployment.'
}
if(!$Env:TenantId) {
    $Env:TenantId = Read-Host -Prompt 'Please provide the Directory (tenant) ID for the service principal.'
}
