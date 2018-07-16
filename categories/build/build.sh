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

if ! type dotnet > /dev/null; then
    D "Prerequisite Check 2: Install .NET Core 2.1 SDK or Runtime"
    exit 1
fi

#if ! type zip > /dev/null; then
#    D "Prerequisite Check 3: Install zip"
#    exit 1
#fi

D "Prerequisites satisfied"
D "******* BUILDING ARTIFACTS *******"

#shift $((OPTIND - 1))
D "Categories Build: Building Categories Microservice in `pwd`"

cd $HOME/src/ContentReactor.Categories
D "Categories Build: Running dotnet build in `pwd`"
dotnet build
D "Categories Build: Ran dotnet build in `pwd`"

cd $HOME/src/ContentReactor.Categories/ContentReactor.Categories.Services.Tests
D "Categories Build: Running dotnet test in `pwd`"
dotnet test
D "Categories Build: Ran dotnet test in `pwd`"

cd $HOME/src/ContentReactor.Categories
D "Categories Build: Running dotnet test in `pwd`"
dotnet publish -c Release
D "Categories Build: Ran dotnet test in `pwd`"

cd $HOME/build
D "Running npm install."
npm install
D "Ran npm install."

D "Categories Build: Zipping the API in `pwd`"
node zip.js \
$HOME/deploy/ContentReactor.Categories.Api.zip \
$HOME/src/ContentReactor.Categories/ContentReactor.Categories.Api/bin/Release/netstandard2.0/publish
D "Categories Build: Zipped the API in `pwd`"

D "Categories Build: Zipping the Worker in `pwd`"
node zip.js \
$HOME/deploy/ContentReactor.Categories.WorkerApi.zip \
$HOME/src/ContentReactor.Categories/ContentReactor.Categories.WorkerApi/bin/Release/netstandard2.0/publish
D "Categories Build: Zipped the Worker in `pwd`"

D "Categories Build: Copy over the latest version of the deploy-microservice.sh script."
node copy-deploy-microservice.js 
D "Categories Build: Copied over the latest version of the deploy-microservice.sh script."

cd $HOME
D "Categories Build: Built Categories Microservice in `pwd`"
