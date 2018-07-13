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
D "Text Build: Building Text Microservice in `pwd`"

cd $HOME/src/ContentReactor.Text
D "Text Build: Running dotnet build in `pwd`"
dotnet build
D "Text Build: Ran dotnet build in `pwd`"

cd $HOME/src/ContentReactor.Text/ContentReactor.Text.Services.Tests
D "Text Build: Running dotnet test in `pwd`"
dotnet test
D "Text Build: Ran dotnet test in `pwd`"

cd $HOME/src/ContentReactor.Text
D "Text Build: Running dotnet test in `pwd`"
dotnet publish -c Release
D "Text Build: Ran dotnet test in `pwd`"

cd $HOME/src/ContentReactor.Text/ContentReactor.Text.Api/bin/Release/netstandard2.0
D "Text Build: Zipping the API in `pwd`"
zip -r ContentReactor.Text.Api.zip .
D "Text Build: Zipped the API in `pwd`"

cd $HOME
D "Text Build: Built Text Microservice in `pwd`"