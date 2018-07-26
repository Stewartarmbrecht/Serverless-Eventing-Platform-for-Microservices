param([String]$namePrefix,[String]$region)
$resourceGroupName = "$namePrefix-events"
$deploymentFile = ".\template.json"
$deploymentParameters = "uniqueResourceNamePrefix=$namePrefix"

function D([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourceGroupName Deployment: $value"  -ForegroundColor DarkCyan }
function E([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourceGroupName Deployment: $value"  -ForegroundColor DarkRed }

# Categories Microservice Deploy

D("Setting location to the scripts folder")
Set-Location $PSSCriptRoot

D("Working in $(Get-Location)")
D("Name Prefix: $namePrefix")
D("Region: $region")

D("Creating the $resourceGroupName resource group in the $region region.")
az group create -n $resourceGroupName -l $region
D("Created the $resourceGroupName resource group in the $region region.")

D("Executing the $resourceGroupName deployment.")
D("`tUsing file: $deploymentFile")
D("`tUsing parameters: $deploymentParameters")
az group deployment create -g $resourceGroupName --template-file $deploymentFile --parameters $deploymentParameters --mode Complete
D("Executed the $resourceGroupName deployment.")

D("Completed $resourceGroupName deployment.")