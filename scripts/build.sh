#!/bin/bash

set -e
set -u

D() { echo -e '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }
E() { echo -e '\033[1;31m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }

cd "${0%/*}"

D "Categories Microservice Build"
chmod u+x ../categories/build/build.sh
time ../categories/build/build.sh

D "Images Microservice Build"
chmod u+x ../images/build/build.sh
time ../images/build/build.sh

D "Audio Microservice Build"
chmod u+x ../audio/build/build.sh
time ../audio/build/build.sh

D "Text Microservice Build"
chmod u+x ../text/build/build.sh
time ../text/build/build.sh

D "Build Proxy"
chmod u+x ../proxy/build/build.sh
time ../proxy/build/build.sh

D "Build Web"
chmod u+x ../web/build/build.sh
time ../web/build/build.sh

D "Buildment complete for $uniquePrefixString!"
