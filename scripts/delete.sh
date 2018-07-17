#!/bin/sh

set -e
set -u

cd "${0%/*}"


D() { D '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }

D "Logging In"
az login
# D "Setting subcription id"
# az account set --subscription $subscriptionId 

D "Deleting Events Resource Group"
az group delete -n $uniquePrefixString"-events" --no-wait -y
D "Deleting categories Resource Group"
az group delete -n $uniquePrefixString"-categories" --no-wait -y
D "Deleting Audio Resource Group"
az group delete -n $uniquePrefixString"-audio" --no-wait -y
D "Deleting Text Resource Group"
az group delete -n $uniquePrefixString"-text" --no-wait -y
D "Deleting Images Resource Group"
az group delete -n $uniquePrefixString"-images" --no-wait -y
D "Deleting Proxy Resource Group"
az group delete -n $uniquePrefixString"-proxy" --no-wait -y
D "Deleting Web Resource Group"
az group delete -n $uniquePrefixString"-web" --no-wait -y
