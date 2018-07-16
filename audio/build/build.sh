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
D "Audio Build: Building Audio Microservice in `pwd`"

cd $HOME/src/ContentReactor.Audio
D "Audio Build: Running dotnet build in `pwd`"
dotnet build
D "Audio Build: Ran dotnet build in `pwd`"

cd $HOME/src/ContentReactor.Audio/ContentReactor.Audio.Services.Tests
D "Audio Build: Running dotnet test in `pwd`"
dotnet test
D "Audio Build: Ran dotnet test in `pwd`"

cd $HOME/src/ContentReactor.Audio
D "Audio Build: Running dotnet test in `pwd`"
dotnet publish -c Release
D "Audio Build: Ran dotnet test in `pwd`"

cd $HOME/build
D "Running npm install."
npm install
D "Ran npm install."

D "Audio Build: Zipping the API in `pwd`"
node zip.js \
$HOME/deploy/ContentReactor.Audio.Api.zip \
$HOME/src/ContentReactor.Audio/ContentReactor.Audio.Api/bin/Release/netstandard2.0/publish
D "Audio Build: Zipped the API in `pwd`"

D "Audio Build: Zipping the Worker in `pwd`"
node zip.js \
$HOME/deploy/ContentReactor.Audio.WorkerApi.zip \
$HOME/src/ContentReactor.Audio/ContentReactor.Audio.WorkerApi/bin/Release/netstandard2.0/publish
D "Audio Build: Zipped the Worker in `pwd`"

D "Audio Build: Copy over the latest version of the deploy-microservice.sh script."
node copy-deploy-microservice.js 
D "Audio Build: Copied over the latest version of the deploy-microservice.sh script."

cd $HOME
D "Audio Build: Built Audio Microservice in `pwd`"
