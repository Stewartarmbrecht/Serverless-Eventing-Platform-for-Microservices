# Content Reactor: Manual Build and Deployment

## System Prep

Content Reactor can be built manually (without using VSTS) by using the same
bash scripts used in the VSTS build process.  To run the scripts, your machine 
will need the following:

1. Bash Shell (for Windows, [install WSL with Ubuntu](https://docs.microsoft.com/en-us/windows/wsl/install-win10))
        2. For windows you might need to run `fromdos` command on the bash scripts to convert them from dos to unix.  
        To install from dos, do the following:
    
    Install
        sudo apt-get update
        sudo apt-get install tofrodos

    Execute
        fromdos ./build.sh # (or other script name)

2. node Version > 8

        curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash
        sudo apt-get install -y nodejs

3. [dotnet CLI version 2.1.x](https://www.microsoft.com/net/learn/get-started/linux/ubuntu16-04)
4. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest)
5. Big Huge API Key

## Build

From the root folder of the repository execute the following commands on the Ubuntu WSL:

        chmod u+x ./scripts/build.sh # if you get a permission denied error.
        ./scripts/build.sh

If you would like to build a single resource group (microservice) run one of the following commands in bash:

        # Run `chmod u+x {path to script}` if you are denied permission to execute any of these scripts.

         ./events/build/build.sh
         ./categories/build/build.sh
         ./audio/build/build.sh
         ./text/build/build.sh
         ./images/build/build.sh
         ./proxy/build/build.sh
         ./web/build/build.sh

## Deploy

From the root folder of the repository (after you have run the build scripts at least once) 
execute the following commands on the Ubuntu WSL:

        chmod u+x ./scripts/deploy.sh # if you get a permission denied error.
        ./scripts/deploy.sh

To run deployments in parallel (where possible) for a 4x faster deploy time, 
run the following in bash:

        chmod u+x ./scripts/deploy-parallel.sh
        ./scripts/deploy-parallel.sh

If you would like to deploy a single resource group run one of the following scripts in bash:

        # Run this before any script:
        az login
        az account set --subscription {your-subscription-id-if-not-the-default}

        # Run one of these for a deployment (after you have run the build for the component at least once)
        ./events/deploy/deploy.sh
        ./categories/deploy/deploy.sh
        ./audio/deploy/deploy.sh
        ./text/deploy/deploy.sh
        ./images/deploy/deploy.sh
        ./proxy/deploy/deploy.sh
        ./web/deploy/deploy.sh
