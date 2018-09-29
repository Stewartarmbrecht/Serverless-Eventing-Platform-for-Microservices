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

Set-Location "$PSSCriptRoot"

. ./../../scripts/functions.ps1

if (!$namePrefix) {
    D "Either pass in the '-namePrefix' parameter when calling this script or 
    set and environment variable with the name: 'namePrefix'." $loggingPrefix
}
if (!$region) {
    D "Either pass in the '-region' parameter when calling this script or 
    set and environment variable with the name: 'region'." $loggingPrefix
}

D "Deploying the web server." $loggingPrefix

$command = "`$webInstrumentationKey=`$`(az resource show --namespace microsoft.insights --resource-type components --name $webAIName -g $resourceGroupName --query properties.InstrumentationKey`)
dir ./.dist/wwwroot/main.*.bundle.js | ForEach {(Get-Content `$_).replace('""%INSTRUMENTATION_KEY%""', ""`$webInstrumentationKey"") | Set-Content `$_}" 
$result = ExecuteCommand $command $loggingPrefix "Updating the instrumentation key in the web app."

$path = "./.dist/**"
$destination = "./ContentReactor.Web.zip"
$command = "Remove-Item -Path $destination -ErrorAction Ignore"
$result = ExecuteCommand $command $loggingPrefix "Removing the web server zip package."

$command = "Compress-Archive -Path $path -DestinationPath $destination"
$result = ExecuteCommand $command $loggingPrefix "Creating the new zip package."

$old_ErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

$command = "az webapp deployment source config-zip --resource-group $resourceGroupName --name $webAppName --src ./ContentReactor.Web.zip"
$result = ExecuteCommand $command $loggingPrefix "Deploying the new web server."

$ErrorActionPreference = $old_ErrorActionPreference 
