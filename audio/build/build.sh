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

shift $((OPTIND - 1))
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

cd $HOME/src/ContentReactor.Audio/ContentReactor.Audio.Api/bin/Release/netstandard2.0
D "Audio Build: Zipping the API in `pwd`"
zip -r ContentReactor.Audio.Api.zip .
D "Audio Build: Zipped the API in `pwd`"

cd $HOME/src/ContentReactor.Audio/ContentReactor.Audio.WorkerApi/bin/Release/netstandard2.0
D "Audio Build: Zipping the Worker in `pwd`"
zip -r ContentReactor.Audio.WorkerApi.zip .
D "Audio Build: Zipped the Worker in `pwd`"

cd $HOME
D "Audio Build: Built Audio Microservice in `pwd`"
