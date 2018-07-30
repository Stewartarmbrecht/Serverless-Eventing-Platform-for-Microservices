param([String]$namePrefix,[String]$region)
if (!$namePrefix) {
    $namePrefix = $Env:namePrefix
}
if (!$region) {
    $region = $Env:region
}
$loggingPrefix = "Web Deployment ($namePrefix)"
$resourceGroupName = "$namePrefix-web"
$webAIName = "$namePrefix-web-ai"
$webAppName = "$namePrefix-web-app"
$deploymentFile = "./microservice.json"
$eventsResourceGroupName = "$namePrefix-events"

Set-Location "$PSSCriptRoot"

. ./../../scripts/functions.ps1

$directoryStart = Get-Location

if (!$namePrefix) {
    D "Either pass in the '-namePrefix' parameter when calling this script or 
    set and environment variable with the name: 'namePrefix'." $loggingPrefix
}
if (!$region) {
    D "Either pass in the '-region' parameter when calling this script or 
    set and environment variable with the name: 'region'." $loggingPrefix
}

D "Deploying the web server." $loggingPrefix

$command = "az group create -n $resourceGroupName -l $region" 
ExecuteCommand $command $loggingPrefix "Creating the resource group."

$command = "az group deployment create -g $resourceGroupName --template-file ./template.json --parameters uniqueResourceNamePrefix=$namePrefix"
ExecuteCommand $command $loggingPrefix "Deploying the infrastructure."

$command = "`$webInstrumentationKey=`$`(az resource show --namespace microsoft.insights --resource-type components --name $webAIName -g $resourceGroupName --query properties.InstrumentationKey`)
dir ./.dist/wwwroot/main.*.bundle.js | ForEach {(Get-Content `$_).replace('""%INSTRUMENTATION_KEY%""', ""$webInstrumentationKey"") | Set-Content `$_}" 
ExecuteCommand $command $loggingPrefix "Updating the instrumentation key in the web app."

$path = "./.dist/**"
$destination = "./ContentReactor.Web.zip"
$command = "Remove-Item -Path $destination -ErrorAction Ignore"
ExecuteCommand $command $loggingPrefix "Removing the web server zip package."

$command = "Compress-Archive -Path $path -Destination $destination"
ExecuteCommand $command $loggingPrefix "Creating the new zip package."

$command = "az webapp deployment source config-zip --resource-group $resourceGroupName --name $webAppName --src ./ContentReactor.Web.zip"
ExecuteCommand $command $loggingPrefix "Deploying the new web server."

 $command = "az group deployment create -g $eventsResourceGroupName --template-file ./eventGridSubscriptions-web.json --parameters uniqueResourceNamePrefix=$namePrefix"
 ExecuteCommand $command $loggingPrefix "Deploying the event grid subscription."