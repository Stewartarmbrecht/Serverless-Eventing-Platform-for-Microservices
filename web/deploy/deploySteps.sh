#!/bin/bash
set -e
set -u

cd "${0%/*}"

D() { echo -e '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }
# Deploy Web

D "Web Deploy: Creating web resource group for $1."
time az group create -n "$1-web" -l westus2
D "Web Deploy: Created web resource group for $1."

time sleep 5

D "Web Deploy: Executing web deployment for $1."
time az group deployment create -g "$1-web" --template-file ./template.json --parameters uniqueResourceNamePrefix=$1
D "Web Deploy: Executed web deployment for $1."

time sleep 5

D "Web Deploy: Running npm install in bulid folder."
npm install
D "Web Deploy: Ran npm install in build folder."

D "Web Deploy: Finding InstrumentationKey"
WEB_APP_NAME="$1-web-app"
time webInstrumentationKey="$(az resource show --namespace microsoft.insights --resource-type components --name $1-web-ai -g $1-web --query properties.InstrumentationKey)"
D "Web Deploy: Found InstrumentationKey $webInstrumentationKey"

D "Web Deploy: Updating web environment.js %INSTRUMENTATION_KEY% with value: $webInstrumentationKey"
time sed -i -e 's/\"%INSTRUMENTATION_KEY%\"/'"$webInstrumentationKey"'/g' ./.dist/wwwroot/main.*.bundle.js
D "Web Deploy: Updated web environment.js %INSTRUMENTATION_KEY% with value: $webInstrumentationKey"

D "Web Deploy: Zipping the web app"
node zip.js ./SignalRMiddleware.zip ./.dist
D "Web Deploy: Zipped the web app"

time sleep 5

D "Web Deploy: Deploying the web app for $1."
time az webapp deployment source config-zip --resource-group "$1-web" --name $WEB_APP_NAME --src ./SignalRMiddleware.zip
D "Web Deploy: Deployed the web app for $1."

time sleep 5

D "Web Deploy: Creating the web app event grid subscription for $1."
time az group deployment create -g "$1-events" --template-file ./eventGridSubscriptions-web.json --parameters uniqueResourceNamePrefix=$1
D "Web Deploy: Created the web app event grid subscription for $1."

time sleep 5

D "Completed web deployment for $1."