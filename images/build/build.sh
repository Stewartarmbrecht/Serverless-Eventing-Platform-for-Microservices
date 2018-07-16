#!/bin/bash
set -e
set -u

cd "${0%/*}"
cd ../
HOME=`pwd`

D() { echo -e '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }

D "Checking for prerequisites..."
if ! type npm > /dev/null; then
    D "Prerequisite Check 1: Install Node.js and NPM"
    exit 1
fi

if ! type dotnet > /dev/null; then
    D "Prerequisite Check 2: Install .NET Core 2.1 SDK or Runtime"
    exit 1
fi

D "Prerequisites satisfied"
D "******* BUILDING ARTIFACTS *******"

#shift $((OPTIND - 1))
D "Images Build: Building Images Microservice in `pwd`"

cd $HOME/src/ContentReactor.Images
D "Images Build: Running dotnet build in `pwd`"
dotnet build
D "Images Build: Ran dotnet build in `pwd`"

cd $HOME/src/ContentReactor.Images/ContentReactor.Images.Services.Tests
D "Images Build: Running dotnet test in `pwd`"
dotnet test
D "Images Build: Ran dotnet test in `pwd`"

cd $HOME/src/ContentReactor.Images
D "Images Build: Running dotnet test in `pwd`"
dotnet publish -c Release
D "Images Build: Ran dotnet test in `pwd`"

cd $HOME/build
D "Running npm install."
npm install
D "Ran npm install."

D "Images Build: Zipping the API in `pwd`"
node zip.js \
$HOME/deploy/ContentReactor.Images.Api.zip \
$HOME/src/ContentReactor.Images/ContentReactor.Images.Api/bin/Release/netstandard2.0/publish
D "Images Build: Zipped the API in `pwd`"

D "Images Build: Zipping the Worker in `pwd`"
node zip.js \
$HOME/deploy/ContentReactor.Images.WorkerApi.zip \
$HOME/src/ContentReactor.Images/ContentReactor.Images.WorkerApi/bin/Release/netstandard2.0/publish
D "Images Build: Zipped the Worker in `pwd`"

D "Images Build: Copy over the latest version of the deploy-microservice.sh script."
node copy-deploy-microservice.js 
D "Images Build: Copied over the latest version of the deploy-microservice.sh script."

cd $HOME
D "Images Build: Built Images Microservice in `pwd`"
