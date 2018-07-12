#!/bin/bash
set -e
set -u

cd "${0%/*}"


D() { echo -e '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }


# Deploy Web
D "Creating web resource group for $1."
time az group create -n $1"-web" -l westus2
D "Created web resource group for $1."

time sleep 2

D "Executing web deployment for $1."
time az group deployment create -g $1"-web" --template-file ./template.json --parameters uniqueResourceNamePrefix=$1
D "Executed web deployment for $1."

time sleep 2

D "Updating web environment.js %INSTRUMENTATION_KEY%"
WEB_APP_NAME=$1"-web-app"
time webInstrumentationKey=$(az resource show --namespace microsoft.insights --resource-type components --name $1-web-ai -g $1-web --query properties.InstrumentationKey)
time sed -i -e 's/\"%INSTRUMENTATION_KEY%\"/'"$webInstrumentationKey"'/g' ../src/signalr-web/SignalRMiddleware/EventApp/src/environments/environment.ts
time sed -i -e 's/\"%INSTRUMENTATION_KEY%\"/'"$webInstrumentationKey"'/g' ../src/signalr-web/SignalRMiddleware/EventApp/src/environments/environment.prod.ts
D "Updated web environment.js %INSTRUMENTATION_KEY%"

D "Running npm install for $1."
cd ../src/signalr-web/SignalRMiddleware/EventApp
time npm install
D "Ran npm install for $1."

D "Running npm unbuntu-dev-build for $1."
time npm run ubuntu-dev-build
D "Ran npm unbuntu-dev-build for $1."

D "Running dotnet publish for $1."
cd ../SignalRMiddleware
time dotnet publish -c Release
D "Ran dotnet publish for $1."

D "Running zip for $1."
cd ./bin/Release/netcoreapp2.1/publish/
time zip -r SignalRMiddleware.zip .
D "Ran zip for $1."

# back up 7 folders to 
# src src/singlr-web/SignalRMMiddleware/SignalRMMiddleware/bin/Release/netcoreapp2.1/publish/
cd ../../../../../../../ 

D "Deploying the web app for $1."
time az webapp deployment source config-zip --resource-group $1"-web" --name $WEB_APP_NAME --src ../src/signalr-web/SignalRMiddleware/SignalRMiddleware/bin/Release/netcoreapp2.1/publish/SignalRMiddleware.zip
D "Deployed the web app for $1."

time sleep 2

D "Creating the web app event grid subscription for $1."
time az group deployment create -g $1"-events" --template-file ./eventGridSubscriptions.json --parameters uniqueResourceNamePrefix=$1
D "Created the web app event grid subscription for $1."

time sleep 2

D "Completed web deployment for $1."
