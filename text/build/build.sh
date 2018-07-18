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
D "Text Build: Building Text Microservice in `pwd`"

cd $HOME/src/ContentReactor.Text
D "Text Build: Running dotnet build in `pwd`"
dotnet build
D "Text Build: Ran dotnet build in `pwd`"

cd $HOME/src/ContentReactor.Text/ContentReactor.Text.Services.Tests
D "Text Build: Running dotnet test in `pwd`"
dotnet test --logger trx;logFileName=testResults.trx
D "Text Build: Ran dotnet test in `pwd`"

cd $HOME/src/ContentReactor.Text
D "Text Build: Running dotnet test in `pwd`"
dotnet publish -c Release
D "Text Build: Ran dotnet test in `pwd`"

cd $HOME/build
D "Running npm install."
npm install
D "Ran npm install."

D "Text Build: Zipping the API in `pwd`"
node zip.js \
$HOME/deploy/ContentReactor.Text.Api.zip \
$HOME/src/ContentReactor.Text/ContentReactor.Text.Api/bin/Release/netstandard2.0/publish
D "Text Build: Zipped the API in `pwd`"

D "Text Build: Copy over the latest version of the deploy-microservice.sh script."
node copy-deploy-microservice.js 
D "Text Build: Copied over the latest version of the deploy-microservice.sh script."

cd $HOME
D "Text Build: Built Text Microservice in `pwd`"
