#!/bin/bash
set -e
set -u

cd "${0%/*}"

D() { echo -e '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }

# Creating Event Grid Topic

D "Creating event grid resource group for $1."
time az group create -n $1"-events" -l westus2
D "Created event grid resource group for $1"

time sleep 2

D "Creating event grid topic for $1."
EVENT_GRID_TOPIC_NAME=$1"-events-topic"
time az group deployment create -g $1"-events" --template-file ./template.json --mode Complete --parameters uniqueResourceNamePrefix=$1
D "Created event grid topic for $1."

D "Completed events deployment for $1."
