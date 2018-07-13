#!/bin/bash

set -e
set -u

D() { echo -e '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }
E() { echo -e '\033[1;31m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }

cd "${0%/*}"

D "Categories Microservice Build"
time ../categories/build/build.sh

D "Images Microservice Build"

time ../images/build/build.sh

D "Audio Microservice Build"

time ../audio/build/build.sh

D "Text Microservice Build"

time ../text/build/build.sh

D "Build Proxy"
time ../proxy/build/build.sh

D "Build Web"
time ../web/build/build.sh

D "Buildment complete for $uniquePrefixString!"