param([String]$namePrefix,[String]$region)
$resourceGroupName = "$namePrefix-web"
$webAIName = "$namePrefix-web-ai"
$webAppName = "$namePrefix-web-app"
$deploymentFile = ".\microservice.json"
$eventsResourceGroupName = "$namePrefix-events"

function D([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourceGroupName Deployment: $value"  -ForegroundColor DarkCyan }
function E([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourceGroupName Deployment: $value"  -ForegroundColor DarkRed }

# Web Deploy

D("Setting location to the scripts folder")
Set-Location $PSSCriptRoot

D("Creating web resource group for $resourceGroupName.")
az group create -n "$resourceGroupName" -l $region
D("Created web resource group for $resourceGroupName.")

D("Executing web deployment for $resourceGroupName.")
az group deployment create -g "$resourceGroupName" --template-file ./template.json --parameters uniqueResourceNamePrefix=$namePrefix
D("Executed web deployment for $resourceGroupName.")

D("Running npm install in bulid folder.")
npm install
D("Ran npm install in build folder.")

D("Finding InstrumentationKey")
$webInstrumentationKey="$(az resource show --namespace microsoft.insights --resource-type components --name $webAIName -g $resourceGroupName --query properties.InstrumentationKey)"
D("Found InstrumentationKey $webInstrumentationKey")

D("Updating web environment.js %INSTRUMENTATION_KEY% with value: $webInstrumentationKey")
dir ./.dist/wwwroot/main.*.bundle.js | ForEach {(Get-Content $_).replace('"%INSTRUMENTATION_KEY%"', $webInstrumentationKey) | Set-Content $_}
D("Updated web environment.js %INSTRUMENTATION_KEY% with value: $webInstrumentationKey")

D("Zipping the web app")
node zip.js ./SignalRMiddleware.zip ./.dist
D("Zipped the web app")

D("Deploying the web app for $resourceGroupName.")
az webapp deployment source config-zip --resource-group "$resourceGroupName" --name "$webAppName" --src ./SignalRMiddleware.zip
D("Deployed the web app for $resourceGroupName.")

D("Creating the web app event grid subscription for $resourceGroupName.")
az group deployment create -g $eventsResourceGroupName --template-file ./eventGridSubscriptions-web.json --parameters uniqueResourceNamePrefix=$namePrefix
D("Created the web app event grid subscription for $resourceGroupName.")

D("Completed web deployment for $resourceGroupName.")