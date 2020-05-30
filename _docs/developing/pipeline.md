# Pipeline Overview
To run the pipeline for a service, run the following scripts:

## Configure Environment
Prior to any script, you need to configure your environment.

1. Configure Environment 
        
        ./Configure-Environment.ps1 `
                -InstanceName "YourUniqueInstanceName" `
                -Region "YourAzureRegion" `
                -UserName "YourServicePrincipalName" `
                -Password "YourServicePrincipalPassword"  `
                -TenantId "YourTenantId" `
                -UniqueDeveloperId "YourUniqueDeveloperTag"

## First Time
Prior to running the service locally, you need to deploy the service and then copy the settings to your local environment.

2. Deploy Infastructure - Deploy the infastructure that will host the service applications.

        ./Deploy-Infrastructure.ps1 -Verbose

3. Setup Local Environment - This copies down the settings from the 

Not finished...