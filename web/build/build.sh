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

if ! type zip > /dev/null; then
    D "Prerequisite Check 3: Install zip"
    exit 1
fi

D "Prerequisites satisfied"
D "******* BUILDING ARTIFACTS *******"

mkdir $HOME/src/signalr-web/SignalRMiddleware/SignalRMiddleware/wwwroot || D "Web Build: wwwroot exists."

cd $HOME/src/signalr-web/SignalRMiddleware/EventApp
D "Web Build: Running npm install in `pwd`"
time npm install
D "Web Build: Ran npm install in `pwd`"

D "Web Build: Running npm build in `pwd`."
time npm run ubuntu-build
D "Web Build: Ran npm build in `pwd`."

cd $HOME/src/signalr-web/SignalRMiddleware/
D "Web Build: Running dotnet build in `pwd`"
dotnet build
D "Web Build: Running dotnet build in `pwd`"

cd $HOME/src/signalr-web/SignalRMiddleware/SignalRMiddlewareTests/
D "Web Build: Running dotnet test in `pwd`"
dotnet test
D "Web Build: Ran dotnet test in `pwd`"

cd $HOME/src/signalr-web/SignalRMiddleware/SignalRMiddleware
D "Web Build: Running dotnet publish in `pwd`."
time dotnet publish -c Release
D "Web Build: Ran dotnet publish in `pwd`."

cd $HOME/build
D "Web Build: Running npm install in bulid folder."
npm install
D "Web Build: Ran npm install in build folder."

D "Web Build: Copying the web app in `pwd`"
node copy-directory.js \
$HOME/deploy/.dist \
$HOME/src/signalr-web/SignalRMiddleware/SignalRMiddleware/bin/Release/netcoreapp2.1/publish
D "Web Build: Copied the web app in `pwd`"

D "Web Build: Copy over the latest version of the deploy-microservice.sh script."
node copy-deploy-microservice.js 
D "Web Build: Copied over the latest version of the deploy-microservice.sh script."

D "Build successfully completed!"
