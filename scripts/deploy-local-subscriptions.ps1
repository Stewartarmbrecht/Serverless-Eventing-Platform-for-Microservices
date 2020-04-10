param(  
    [Alias("v")]
    [String] $verbosity,
    [Alias("u")]
    [String] $publicUrlToLocalWebServer
)
$currentDirectory = Get-Location

Set-Location "$PSScriptRoot"

$location = Get-Location

. ./functions.ps1

./configure-env.ps1

$systemName = $Env:systemName
$solutionName = $Env:solutionName
$microserviceName = $Env:microserviceName
$apiPort = $Env:apiPort
$workerPort = $Env:workerPort
$userName = $Env:userName
$password = $Env:password
$tenantId = $Env:tenantId
$uniqueDeveloperId = $Env:uniqueDeveloperId

$loggingPrefix = "$systemName $microserviceName Deploy Local Subscriptions"

$eventsResourceGroupName = "$systemName-events"

D "Deploying the web server subscriptions." $loggingPrefix

$old_ErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

# https://github.com/Microsoft/azure-pipelines-agent/issues/1816
$command = "az"
$result = ExecuteCommand $command $loggingPrefix "Executing first AZ call to get around Task bug."
if ($verbosity -eq "Normal" -or $verbosity -eq "n")
{
    $result
}

$ErrorActionPreference = $old_ErrorActionPreference 

$command = "az login --service-principal --username $userName --password $password --tenant $tenantId"
$result = ExecuteCommand $command $loggingPrefix "Logging in the Azure CLI."
if ($verbosity -eq "Normal" -or $verbosity -eq "n")
{
    $result
}

$expireTime = Get-Date
$expireTimeUtc = $expireTime.AddHours(1).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$command = "az group deployment create -g $eventsResourceGroupName --template-file ./../$microserviceName/templates/eventGridSubscriptions.local.json --parameters uniqueResourcesystemName=$systemName publicUrlToLocalWebServer=$publicUrlToLocalWebServer uniqueDeveloperId=$uniqueDeveloperId expireTimeUtc=$expireTimeUtc"
$result = ExecuteCommand $command $loggingPrefix "Deploying the event grid subscription."
if ($verbosity -eq "Normal" -or $verbosity -eq "n")
{
    $result
}

D "Deployed the subscriptions." $loggingPrefix