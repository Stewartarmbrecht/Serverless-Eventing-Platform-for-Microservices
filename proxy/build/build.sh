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
D "Proxy Build: Building Proxy Microservice in `pwd`"

cd $HOME/proxies
D "Proxy Build: Zipping the API in `pwd`"
zip -r ContentReactor.Proxy.Api.zip .
D "Proxy Build: Zipped the API in `pwd`"

cd $HOME
D "Proxy Build: Built Proxy Microservice in `pwd`"