#!/bin/bash

usage()
{
    echo -e "This script creats a generic function based microservice.  It responds to the following parameters."
    echo -e ""
    echo -e "./deploy-parallel.sh"
    echo -e "\t-h --help"
    echo -e "\t--servicePrincipalAppId: The id of the service principal app to use to connect to Azure."
    echo -e "\t--servicePrincipalPassword: The services principal's password."
    echo -e "\t--servicePrincipalTenantId: The tenant Id to use."
    echo -e "\t--subscriptionId: The subscription id to deploy to."
    echo -e "\t--bigHugeThesaurusApiKey: Get this key from 'https://words.bighugelabs.com/api.php'"
    echo -e "\t--uniquePrefixString: A string that will be prepended to every resource.  \033[1;31mMUST BE GLOBALLY UNIQUE and SHOULD ONLY CONTAIN LETTERS AND NUMBERS!\033[0m"
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

set -e
set -u

D() { echo -e '\033[1;35m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }
E() { echo -e '\033[1;31m'`date +%Y-%m-%d-%H:%M:%S` $1'\033[0m'; }

cd "${0%/*}"

D "Logging in."
time az login --service-principal --username $servicePrincipalAppId --password $servicePrincipalPassword --tenant $servicePrincipalTenantId

D "Setting subscription."
time az account set --subscription $subscriptionId 

# Creating Event Grid Topic
chmod u+x ../events/deploy/deploySteps.sh
time ../events/deploy/deploySteps.sh $uniquePrefixString

# Categories Microservice Deploy
chmod u+x ../categories/deploy/deploySteps.sh 
time ../categories/deploy/deploySteps.sh $uniquePrefixString $bigHugeThesaurusApiKey &

# Images Microservice Deploy
chmod u+x ../images/deploy/deploySteps.sh 
time ../images/deploy/deploySteps.sh $uniquePrefixString &

# Audio Microservice Deploy
chmod u+x ../audio/deploy/deploySteps.sh
time ../audio/deploy/deploySteps.sh $uniquePrefixString &

# Text Microservice Deploy
chmod u+x ../text/deploy/deploySteps.sh 
time ../text/deploy/deploySteps.sh $uniquePrefixString &

wait

# Deploy Proxy
chmod u+x ../proxy/deploy/deploySteps.sh
time ../proxy/deploy/deploySteps.sh $uniquePrefixString &

# Deploy Web
chmod u+x ../web/deploy/deploySteps.sh
time ../web/deploy/deploySteps.sh $uniquePrefixString &

wait 

D "Deployment complete for $uniquePrefixString!"