[CmdletBinding()]
param(
    [switch] $Dev
)
$currentDirectory = Get-Location
Set-Location $PSSCriptRoot

. ./Functions.ps1

./Configure-Environment.ps1

$instanceName = $Env:InstanceName

$loggingPrefix = "ContentReactor API Pipeline $instanceName"

Write-EdenBuildInfo "Running the full pipeline for the events subsystem." $loggingPrefix

./Build-DeploymentPackage.ps1
./Deploy-Service.ps1

Write-EdenBuildInfo "Finished the full pipeline for the API subsystem." $loggingPrefix

Set-Location $currentDirectory