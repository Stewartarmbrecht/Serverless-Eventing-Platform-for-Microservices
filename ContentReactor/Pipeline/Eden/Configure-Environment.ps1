[CmdletBinding()]
param(
    [ValidateLength(3, 18)]
    [String] $ProdInstanceName,
    [ValidateLength(3, 18)]
    [String] $DevInstanceName,
    [String] $Region, 
    [String] $UserName,
    [String] $UserId,
    [SecureString] $Password, 
    [String] $TenantId,
    [String] $SubscriptionId,
    [String] $UniqueDeveloperId
)
. ./Functions.ps1

if ($InstanceName) {
    $loggingPrefix = "ContentReactor Configuration $InstanceName"
} else {
    $loggingPrefix = "ContentReactor Configuration $Env:InstanceName"
}

Write-EdenBuildInfo "Configuring the environment." $loggingPrefix

if ($ProdInstanceName) {
    # [Environment]::SetEnvironmentVariable("InstanceName", $InstanceName, [System.EnvironmentVariableTarget]::Machine)
    $Env:ProdInstanceName = $ProdInstanceName
}
if ($DevInstanceName) {
    # [Environment]::SetEnvironmentVariable("InstanceName", $InstanceName, [System.EnvironmentVariableTarget]::Machine)
    $Env:DevInstanceName = $DevInstanceName
}
if ($Region) {
    # [Environment]::SetEnvironmentVariable("Region", $Region, "User")
    $Env:Region = $Region
}
if ($UserName) {
    # [Environment]::SetEnvironmentVariable("UserName", $UserName, "User")
    $Env:UserName = $UserName
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
if ($SubscriptionId) {
    # [Environment]::SetEnvironmentVariable("TenantId", $TenantId, "User")
    $Env:SubscriptionId = $SubscriptionId
}
if ($UniqueDeveloperId) {
    # [Environment]::SetEnvironmentVariable("UniqueDeveloperId", $UniqueDeveloperId, "User")
    $Env:UniqueDeveloperId = $UniqueDeveloperId
}

if(!$Env:ProdInstanceName) {
    $Env:ProdInstanceName = Read-Host -Prompt 'Please provide a prefix to add to the beginning of every resources for the production instance of the system.  Some resources require globally unique names.  This prefix should guarantee that.'
}
if(!$Env:DevInstanceName) {
    $Env:DevInstanceName = Read-Host -Prompt 'Please provide a prefix to add to the beginning of every resources for the development instance of the system.  Some resources require globally unique names.  This prefix should guarantee that.'
}
if(!$Env:Region) {
    $Env:Region = Read-Host -Prompt 'Please provide a region to deploy to.  Hint: WestUS2'
}
if(!$Env:UserName) {
    $Env:UserName = Read-Host -Prompt 'Please provide the Display Name for a service principal to use for the deployment.'
}
if(!$Env:UserId) {
    $Env:UserId = Read-Host -Prompt 'Please provide the User Id (Application Id) for a service principal to use for the deployment.'
}
if(!$Env:Password) {
    $Env:Password = Read-Host -AsSecureString -Prompt 'Please provide the service principal secret (password) to use for the deployment.'
}
if(!$Env:TenantId) {
    $Env:TenantId = Read-Host -Prompt 'Please provide the Directory (tenant) ID for the service principal.'
}
if(!$Env:SubscriptionId) {
    $Env:SubscriptionId = Read-Host -Prompt 'Please provide the Subscription ID for the service principal.'
}
if(!$Env:UniqueDeveloperId) {
    $Env:UniqueDeveloperId = Read-Host -Prompt 'Please provide a unique id to identify subscriptions deployed to the cloud for the local developer.'
}

$loggingPrefix = "ContentReactor Configuration $Env:InstanceName"
Write-Verbose "Env:InstanceName=$Env:InstanceName"
Write-Verbose "Env:Region=$Env:Region"
Write-Verbose "Env:UserName=$Env:UserName"
Write-Verbose "Env:UserId=$Env:UserId"
Write-Verbose "Env:TenantId=$Env:TenantId"
Write-Verbose "Env:SubscriptionId=$Env:SubscriptionId"
Write-Verbose "Env:UniqueDeveloperId=$Env:UniqueDeveloperId"
Write-EdenBuildInfo "Configured the environment." $loggingPrefix
