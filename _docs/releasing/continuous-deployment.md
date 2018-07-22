# Continuous Deployment

## Naming Convention

**NOTE:** All deployment templates and steps are designed to find other resources using
a specific naming convention that relies on you providing a **single globally unique
string** __***that only contains letters and numbers***__ 
(it will be part of storage account names) and will prefix each resource name. 
This includes the resource groups.
Pick a value now (e.g. 'cr2018') and substitue it where ever you see 
`{your-globally-unique-prefix}`

## VSTS Release Definitions

Each of the subfolders in this repository (`audio`, `categories`, `events`, 
`images`, `proxy`, `text`, and `web`) 
contains a `deploy` subfolder with a `deploySteps.sh` file. The `deploySteps.sh` 
files contains a bash script that executes calls to the Azure CLI to execute 
the deployment.

To use VSTS to deploy the Content Reactor system, you will need to set up multiple 
release configurations - one for each component with a `deploySteps.sh` file. 

Use the following steps:

1. Add a Release Definition
2. Select Empty Process for the template.
2. Add an artifact with 'Build' as the Source type
    1. For the Source, Choose the build definition fromm the previous section that you want to create a release for.
    2. Keep the defaults for the remaining fields.
3. Update the Environment to use the Hosted Linux Preview.
4. Add an Azure CLI step to the Agent Phase.
    1. Set the subscription to the subscription you would like to deploy to.
    2. Set the Script Path to the deploy/deploySteps.sh script (use the '...' button to find the file.)
    3. Set the arguments to a string that will prefix all resources (ex. 'CRProd').  
        1. **The prefix should match across all releases.**
        2. **It should be globally unique and it should only contain letters and numbers (no spaces, dashes, underscores, etc.).  The Prefix is used in storage account names as well.**

After all the release definitions have been created, you need to run the releases for the first time in a specific order. 
To do this, queue releases using those definitions in the following order:

1. Events
2. Categories
3. Audio
4. Text
5. Images
6. Proxy
7. Web

After deployment you should be able to navigate to the following url to validate success:

[http://{your-unique-prefix}-web-app.azurewebsites.net](http://{your-unique-prefix}-web-app.azurewebsites.net)
