param(  
    [Alias("v")]
    [String] $verbosity
)
. ./../scripts/functions.ps1

./../scripts/configure-env.ps1

$systemName = $Env:systemName
$userName = $Env:userName
$password = $Env:password
$tenantId = $Env:tenantId
$region = $Env:region

$loggingPrefix = "$systemName $microserviceName Post Deploy"

$currentDirectory = Get-Location

Set-Location "$PSScriptRoot"

D "Executing post deployment actions." $loggingPrefix

$resourceGroupName = "$systemName-audio"
$storageAccountName = "$($systemName)audioblob".ToLower()
$storageContainerName = "audio"

$old_ErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

# https://github.com/Microsoft/azure-pipelines-agent/issues/1816
$command = "az"
$result = ExecuteCommand $command $loggingPrefix "Executing first AZ call to get around Task bug."

$ErrorActionPreference = $old_ErrorActionPreference 

$command = "az login --service-principal --username $userName --password $password --tenant $tenantId"
$result = ExecuteCommand $command $loggingPrefix "Logging in the Azure CLI"

$command = "az storage container create --account-name $storageAccountName --name $storageContainerName"
$result = ExecuteCommand $command $loggingPrefix "Creating the stoarge container."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

$command = "az storage cors clear --account-name $storageAccountName --services b"
$result = ExecuteCommand $command $loggingPrefix "Clearing the storage account CORS policy."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

$command = "az storage cors add --account-name $storageAccountName --services b --methods POST GET PUT --origins ""*"" --allowed-headers ""*"" --exposed-headers ""*"""
$result = ExecuteCommand $command $loggingPrefix "Creating the storage account CORS policy."
if ($verbosity -eq "Normal" -or $verbosity -eq "n") {
    $result
}

D "Finished the post deployment actions." $loggingPrefix
