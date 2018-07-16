#!/bin/bash
set -e
set -u

D() { echo -e '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }

D "Location: $(pwd)"
D "Location: ${0%/*}"

cd "${0%/*}"

# D "After setting directory to scripts directory: $(pwd)"

cd ../

D "After moving up a level: $(pwd)"

HOME=`pwd`

D "After setting home: $(pwd)"

D "Checking for prerequisites..."
if ! type npm > /dev/null; then
    D "Prerequisite Check 1: Install Node.js and NPM"
    exit 1
fi

D "Prerequisites satisfied"
D "******* BUILDING ARTIFACTS *******"

#shift $((OPTIND - 1))
D "Events Build: Building Events Microservice in `pwd`"

cd $HOME/build
D "Running npm install."
npm install
D "Ran npm install."

D "Categories Build: Copy over the latest version of the deploy-microservice.sh script."
node copy-deploy-microservice.js 
D "Categories Build: Copied over the latest version of the deploy-microservice.sh script."

cd $HOME
D "Events Build: Built Events Microservice in `pwd`"
