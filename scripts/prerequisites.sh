#!/bin/bash

set -e
set -u

D() { echo -e '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }
E() { echo -e '\033[1;31m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }

cd "${0%/*}"

D "Checking for prerequisites..."

if ! type zip > /dev/null; then
    D "Prerequisite Check 3: Install zip"
	apt install zip
    exit 1
fi

D "Prerequisites satisfied"
