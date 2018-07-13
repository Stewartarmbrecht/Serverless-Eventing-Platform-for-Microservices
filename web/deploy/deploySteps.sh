#!/bin/bash
set -e
set -u

cd "${0%/*}"

D() { echo -e '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }


# Deploy Web
D "Creating web resource group for $1."
time az group create -n $1"-web" -l westus2
D "Created web resource group for $1."

time sleep 5

D "Executing web deployment for $1."
time az group deployment create -g $1"-web" --template-file ./template.json --parameters uniqueResourceNamePrefix=$1
D "Executed web deployment for $1."

time sleep 5

D "Finding InstrumentationKey"
WEB_APP_NAME=$1"-web-app"
time webInstrumentationKey=$(az resource show --namespace microsoft.insights --resource-type components --name $1-web-ai -g $1-web --query properties.InstrumentationKey)
D "Found InstrumentationKey $webInstrumentationKey"

D "Updating web environment.js %INSTRUMENTATION_KEY% with value: $webInstrumentationKey"
time sed -i -e 's/\"%INSTRUMENTATION_KEY%\"/'"$webInstrumentationKey"'/g' ../src/signalr-web/SignalRMiddleware/SignalRMiddleware/bin/Release/netcoreapp2.1/publish/wwwroot/main.*.bundle.js
D "Updated web environment.js %INSTRUMENTATION_KEY% with value: $webInstrumentationKey"

cd ../src/signalr-web/SignalRMiddleware/SignalRMiddleware/bin/Release/netcoreapp2.1/publish/
D "Web Build: Zipping the solution in `pwd`."
time zip -r ./SignalRMiddleware.zip .
D "Web Build: Zipped the solution in `pwd`."
cd ../../../../../../../../deploy

time sleep 5

D "Deploying the web app for $1."
time az webapp deployment source config-zip --resource-group $1"-web" --name $WEB_APP_NAME --src ../src/signalr-web/SignalRMiddleware/SignalRMiddleware/bin/Release/netcoreapp2.1/publish/SignalRMiddleware.zip
D "Deployed the web app for $1."

time sleep 5

D "Creating the web app event grid subscription for $1."
time az group deployment create -g $1"-events" --template-file ./eventGridSubscriptions-web.json --parameters uniqueResourceNamePrefix=$1
D "Created the web app event grid subscription for $1."

time sleep 5

D "Completed web deployment for $1."
