#!/bin/sh

cd "${0%/*}"


echo "Run az login and az account set --subecription X if you have not already."
# D "Logging In"
# az login
# D "Setting subcription id"
# az account set --subscription $subscriptionId 

echo "Deleting Events Resource Group"
az group delete -n "$1-events" --no-wait -y

echo "Deleting categories Resource Group"
az group delete -n "$1-categories" --no-wait -y

echo "Deleting Audio Resource Group"
az group delete -n "$1-audio" --no-wait -y

echo "Deleting Text Resource Group"
az group delete -n "$1-text" --no-wait -y

echo "Deleting Images Resource Group"
az group delete -n "$1-images" --no-wait -y

echo "Deleting Proxy Resource Group"
az group delete -n "$1-proxy" --no-wait -y

echo "Deleting Web Resource Group"
az group delete -n "$1-web" --no-wait -y
