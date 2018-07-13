#!/bin/bash
set -e
set -u

cd "${0%/*}"
cd ../
HOME=`pwd`

D() { echo -e '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }

../scripts/prerequisites.sh

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

cd $HOME/src/ContentReactor.Categories/ContentReactor.Categories.Api/bin/Release/netstandard2.0
D "Categories Build: Zipping the API in `pwd`"
zip -r ContentReactor.Categories.Api.zip .
D "Categories Build: Zipped the API in `pwd`"

cd $HOME/src/ContentReactor.Categories/ContentReactor.Categories.WorkerApi/bin/Release/netstandard2.0
D "Categories Build: Zipping the Worker in `pwd`"
zip -r ContentReactor.Categories.WorkerApi.zip .
D "Categories Build: Zipped the Worker in `pwd`"

cd $HOME
D "Categories Build: Built Categories Microservice in `pwd`"
