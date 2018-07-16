#!/bin/bash

#set -x

usage()
{
    echo "This script deploys the categories microservice.  It responds to the following parameters."
    echo ""
    echo "./deploy.sh"
    echo "    -h --help"
    echo "    --servicePrincipalAppId='Guid': The id of the service principal app to use to connect to Azure."
    echo "    --servicePrincipalPassword='Passwprd': The services principal's password."
    echo "    --servicePrincipalTenantId='Guid': The tenant Id to use."
    echo "    --subscriptionId='Guid': The subscription id to deploy to."
    echo "    --bigHugeThesaurusApiKey='Guid': Get this key from 'https://words.bighugelabs.com/api.php'"
    echo "    --uniquePrefixString='String': A string that will be prepended to every resource.  \033[1;31mMUST BE GLOBALLY UNIQUE and SHOULD ONLY CONTAIN LETTERS AND NUMBERS!\033[0m"
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --servicePrincipalAppId)
            servicePrincipalAppId=$VALUE
            ;;
        --servicePrincipalPassword)
            servicePrincipalPassword=$VALUE
            ;;
        --servicePrincipalTenantId)
            servicePrincipalTenantId=$VALUE
            ;;
        --subscriptionId)
            subscriptionId=$VALUE
            ;;
        --bigHugeThesaurusApiKey)
            bigHugeThesaurusApiKey=$VALUE
            ;;
        --uniquePrefixString)
            uniquePrefixString=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

D() { echo '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }
E() { echo '\033[1;31m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }

cd "${0%/*}"

D "Logging in."
time az login --service-principal --username $servicePrincipalAppId --password $servicePrincipalPassword --tenant $servicePrincipalTenantId
D "Setting subscription."
time az account set --subscription $subscriptionId 

# Categories Microservice Deploy
time sh ./deploySteps.sh $uniquePrefixString $bigHugeThesaurusApiKey

D "Categories deployment complete for $uniquePrefixString!"