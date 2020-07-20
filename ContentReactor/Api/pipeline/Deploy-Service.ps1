[CmdletBinding()]
param()

$currentDirectory = Get-Location
Set-Location $PSScriptRoot

. ./Functions.ps1

./Configure-Environment.ps1

$instanceName = $Env:InstanceName

$loggingPrefix = "ContentReactor Api Deploy Service $instanceName"

Write-EdenBuildInfo "Deploying the service." $loggingPrefix

./Deploy-Infrastructure.ps1

./Deploy-Application.ps1

#./Deploy-Subscription.ps1

Write-EdenBuildInfo "Deployed the service." $loggingPrefix

Set-Location $currentDirectory