#!/bin/bash
set -e
set -u

cd "${0%/*}"


D() { echo -e '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }


if [ "$#" -eq 6 ]; then
	servicePrincipalAppId="$1"
	D "Service Principal App Id: $servicePrincipalAppId"
	servicePrincipalPassword="$2"
	D "Service Principal Password: ********"
	servicePrincipalTenantId="$3"
	D "Service Principal Tenant Id: $servicePrincipalTenantId"
	subscriptionId="$4"
	D "Subscription Id: $subscriptionId"
	uniquePrefixString="$5"
	D "Unique Prefix String: $uniquePrefixString"
	bigHugeThesaurusApiKey="$6"
else
	D "Provide Service Principal App ID: "
	read servicePrincipalAppId
	D "Provide Service Principal Password: "
	read servicePrincipalPassword
	D "Provide Service Principal Tenant ID: "
	read servicePrincipalTenantId
	D "Provide subscription ID: "
	read subscriptionId
	D "Provide any unique Prefix string (max length 15 characters, recommended to autogenerate a string): "
	read uniquePrefixString
	D "Provide Big Huge Thesaurus API Key: "
	read bigHugeThesaurusApiKey
fi


D "Logging in."
time az login --service-principal --username $servicePrincipalAppId --password $servicePrincipalPassword --tenant $servicePrincipalTenantId
D "Setting subscription."
time az account set --subscription $subscriptionId 

# Deploy Web
D "Updating web environment.js %INSTRUMENTATION_KEY%"
WEB_APP_NAME=$1"-web-app"
time webInstrumentationKey=$(az resource show --namespace microsoft.insights --resource-type components --name $1-web-ai -g $1-web --query properties.InstrumentationKey)
time sed -i -e 's/\"%INSTRUMENTATION_KEY%\"/'"$webInstrumentationKey"'/g' ../src/signalr-web/SignalRMiddleware/SignalRMiddleware/bin/Release/netcoreapp2.1/publish/wwwroot/main.*.bundle.js
D "Updated web environment.js %INSTRUMENTATION_KEY%"

wait 

D "Deployment complete for $uniquePrefixString!"