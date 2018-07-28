param([String]$namePrefix,[String]$region)
if (!$namePrefix) {
    $namePrefix = $Env:namePrefix
}
if (!$region) {
    $region = $Env:region
}
$resourceGroupName = "$namePrefix-proxy"
$deploymentFile = ".\template.json"
$apiName = "$namePrefix-proxy-api"
$apiFilePath = "./ContentReactor.Proxy.Api.zip"

function D([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourceGroupName Deployment: $value"  -ForegroundColor DarkCyan }
function E([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourceGroupName Deployment: $value"  -ForegroundColor DarkRed }

# Proxy Microservice Deploy

D("Setting location to the scripts folder")
Set-Location $PSSCriptRoot

D("Creating the $resourceGroupName resource group in the $region region.")
az group create -n $resourceGroupName -l $region
D("Created the $resourceGroupName resource group in the $region region.")

D("Executing the $resourceGroupName deployment.")
D("`tUsing file: $deploymentFile")
D("`tUsing parameters: uniqueResourceNamePrefix=$namePrefix")
az group deployment create -g $resourceGroupName --template-file $deploymentFile --mode Complete --parameters uniqueResourceNamePrefix=$namePrefix
D("Executed the $resourceGroupName deployment.")
D("`tUsing file: $deploymentFile")
D("`tUsing parameters: uniqueResourceNamePrefix=$namePrefix")

D("Deploying $resourceGroupName api function:")
D("`tUsing name: $apiName")
D("`tUsing file path: $apiFilePath")
az webapp deployment source config-zip --resource-group $resourceGroupName --name $apiName --src $apiFilePath
D("Deployed $resourceGroupName api function:")
D("`tUsing name: $apiName")
D("`tUsing file path: $apiFilePath")

D("Completed $resourceGroupName deployment..")