[CmdletBinding()]
param(
    [String] $InstanceName,
    [String] $Region, 
    [String] $UserName, 
    [String] $Password, 
    [String] $TenantId, 
    [String] $UniqueDeveloperId,
    [Int] $ApiPort,
    [Int] $WorkerPort
)

if ($InstanceName) {
    # [Environment]::SetEnvironmentVariable("InstanceName", $InstanceName, [System.EnvironmentVariableTarget]::Machine)
    $Env:InstanceName = $InstanceName
}
if ($Region) {
    # [Environment]::SetEnvironmentVariable("Region", $Region, "User")
    $Env:Region = $Region
}
if ($UserName) {
    # [Environment]::SetEnvironmentVariable("UserName", $UserName, "User")
    $Env:UserName = $UserName
}
if ($Password) {
    # [Environment]::SetEnvironmentVariable("Password", $Password, "User")
    $Env:Password = $Password
}
if ($TenantId) {
    # [Environment]::SetEnvironmentVariable("TenantId", $TenantId, "User")
    $Env:TenantId = $TenantId
}
if ($UniqueDeveloperId) {
    # [Environment]::SetEnvironmentVariable("UniqueDeveloperId", $UniqueDeveloperId, "User")
    $Env:UniqueDeveloperId = $UniqueDeveloperId
}
if ($ApiPort) {
    # [Environment]::SetEnvironmentVariable("AudioApiPort", $ApiPort, "User")
    $Env:AudioApiPort = $ApiPort
}
if ($WorkerPort) {
    # [Environment]::SetEnvironmentVariable("AudioWorkerPort", $WorkerPort, "User")
    $Env:AudioWorkerPort = $WorkerPort
}

if(!$Env:InstanceName) {
    $Env:InstanceName = Read-Host -Prompt 'Please provide a prefix to add to the beginning of every resources for the instance of the system.  Some resources require globally unique names.  This prefix should guarantee that.'
}
if(!$Env:Region) {
    $Env:Region = Read-Host -Prompt 'Please provide a region to deploy to.  Hint: WestUS2'
}
if(!$Env:UserName) {
    $Env:UserName = Read-Host -Prompt 'Please provide the Application (client) ID for a service principle to use for the deployment.'
}
if(!$Env:Password) {
    $Env:Password = Read-Host -Prompt 'Please provide the service principal secret (password) to use for the deployment.'
}
if(!$Env:TenantId) {
    $Env:TenantId = Read-Host -Prompt 'Please provide the Directory (tenant) ID for the service principal.'
}
if(!$Env:UniqueDeveloperId) {
    $Env:UniqueDeveloperId = Read-Host -Prompt 'Please provide a unique id to identify subscriptions deployed to the cloud for the local developer.'
}
if(!$Env:AudioApiPort) {
    $Env:AudioApiPort = Read-Host -Prompt 'Please provide the port number for the audio api.'
}
if(!$Env:AudioWorkerPort) {
    $Env:AudioWorkerPort = Read-Host -Prompt 'Please provide the port number for the audio worker.'
}
