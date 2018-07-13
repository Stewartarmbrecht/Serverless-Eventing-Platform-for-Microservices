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

cd $HOME/src/ContentReactor.Images/ContentReactor.Images.Api/bin/Release/netstandard2.0
D "Images Build: Zipping the API in `pwd`"
zip -r ContentReactor.Images.Api.zip .
D "Images Build: Zipped the API in `pwd`"

cd $HOME/src/ContentReactor.Images/ContentReactor.Images.WorkerApi/bin/Release/netstandard2.0
D "Images Build: Zipping the Worker in `pwd`"
zip -r ContentReactor.Images.WorkerApi.zip .
D "Images Build: Zipped the Worker in `pwd`"

cd $HOME
D "Images Build: Built Images Microservice in `pwd`"
