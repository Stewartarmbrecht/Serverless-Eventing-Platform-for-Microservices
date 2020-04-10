# Deploying

_Execute [the build instructions](building.md) prior to 
deploying the solution._

## Deploying Manually

**Note:** When deploying the solution for the first time, 
deploy the entire solution using the master build script to ensure
resources are created in the proper sequence.

You have to deploy the components in the following order:
1. Events
2. Microservices (Audio, Categories, Images, Text)
3. Proxy
4. Web

**IMPORTANT: Your Unique Naming Prefix**

The deployment creates several dependent resources across multiple resource groups.  
We use a naming convention across microservices to find and reference specific components
during the deployment.  You will be required to provide a globally unique naming prefix.

**Please provide the SAME naming prefix for all microservices you deploy for an instance of Content Reactor.**

### Deploying The Entire Solution Manually

1. Open PowerShell and navigate to the root of the repo.
2. Determine a name prefix that:
    * contains only lowercase letters and numbers(no spaces or numbers).
    * is globally unique in Azure when suffixes are added (like `-web`, `-events`, etc.)
3. Execute the primary deployment script:

        ./scripts/deploy.ps1 -systemName {your-name-prefix} -region westus2 -bigHugeThesaurusApiKey {your-api-key}

### Deploying A Single Microservice Manually

1. Open PowerShell and navigate to the deploy folder in the microservice you want to build (ex. `./audio/dploy`).
2. Execute the `deploy.ps1` powershell script.

    * For Categories:

        ./deploy.ps1 -systemName {your-name-prefix} -region westus2 -bigHugeThesaurusApiKey {your-api-key}

    * For all else (Events, Audio, Images, Text, Proxy, Web)

        ./deploy.ps1 -systemName {your-name-prefix} -region westus2

