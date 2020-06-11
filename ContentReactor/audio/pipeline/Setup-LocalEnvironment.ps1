[CmdletBinding()]
param()

$currentDirectory = Get-Location
Set-Location $PSSCriptRoot

. ./Functions.ps1

# Collect the environment settings.
./Configure-Environment.ps1

$instanceName = $Env:InstanceName

$apiPort = $Env:AudioLocalHostingPort

$loggingPrefix = "ContentReactor Audio $instanceName Setup"

./Build-Applications.ps1

./Test-Unit.ps1

./Build-DeploymentPackages.ps1

./Deploy-Infrastructure.ps1

./Deploy-Applications.ps1

./Deploy-Subscriptions.ps1

Set-Location "./../application"
Invoke-BuildCommand "func azure functionapp fetch-app-settings $instanceName-audio" $loggingPrefix "Fetching the app settings from azure."
Invoke-BuildCommand "func settings add ""FUNCTIONS_WORKER_RUNTIME"" ""dotnet""" $loggingPrefix "Adding the run time setting for 'dotnet'."
Invoke-BuildCommand "func settings add ""Host.LocalHttpPort"" ""$apiPort""" $loggingPrefix "Adding the run time port setting for '$apiPort'."

Set-Location $currentDirectory
