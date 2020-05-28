[CmdletBinding()]
param()
$currentDirectory = Get-Location
Set-Location $PSSCriptRoot

. ./Functions.ps1

./Configure-Environment.ps1

$instanceName = $Env:InstanceName

$loggingPrefix = "ContentReactor Audio Pipeline $instanceName"

Write-BuildInfo "Running the full pipeline for the microservice." $loggingPrefix

./Build-Applications.ps1
./Test-Unit.ps1
./Test-EndToEnd.ps1
./Build-DeploymentPackages.ps1
./Deploy-Service.ps1

Write-BuildInfo "Finished the full pipeline for the microservice." $loggingPrefix

Set-Location $currentDirectory