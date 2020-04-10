param([String]$namePrefix)

function D([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourcePrefix Deploy: $value"  -ForegroundColor DarkCyan }
function E([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourcePrefix Deploy: $value"  -ForegroundColor DarkRed }

D("Run az login and az account set --subecription X if you have not already.")

D("Deleting Events Resource Group")
az group delete -n "$namePrefix-events" --no-wait -y

D("Deleting Categories Resource Group")
az group delete -n "$namePrefix-categories" --no-wait -y

D("Deleting Audio Resource Group")
az group delete -n "$namePrefix-audio" --no-wait -y

D("Deleting Text Resource Group")
az group delete -n "$namePrefix-text" --no-wait -y

D("Deleting Images Resource Group")
az group delete -n "$namePrefix-images" --no-wait -y

D("Deleting Health Resource Group")
az group delete -n "$namePrefix-health" --no-wait -y

D("Deleting Proxy Resource Group")
az group delete -n "$namePrefix-proxy" --no-wait -y

D("Deleting Web Resource Group")
az group delete -n "$namePrefix-web" --no-wait -y
