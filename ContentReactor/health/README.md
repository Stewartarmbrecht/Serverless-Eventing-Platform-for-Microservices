# Content Reactor - Health Service
The Content Reactor Health service provides functionality for validating the health of the system.  It provides functionality that calls the health checks on all system services.

## Components
Below is an overview of what is included in the health service by folder:

1. **Infrastructure** - Contains Azure Resource Manager templates:

    1. **infrastructure.json** - Deploys the following:

        1. **instance-health** - Azure functions app service that provides the api of the service.
        1. **instance-health/staging** - Azure functions app service slot that serves as the staging environment for api deployments.
        1. **instance-health-asp** - Applicaiton service plan for hosting the 2 function apps and the 2 corresponding slots.
        1. **instancehltwjs** - Storage account used for information necessary to run the function apps.
        1. **instance-health-ai** - Applicaiton Insights instance that provides monitoring for all components in the service.

1. **Service** - C# Azure Function project. Includes the following functions:

    1. **HealthCheckSystem** - Performs health checks on all system services on demand.
    1. **HealthCheckSystemTimer** - Performs health checks on all system services every 10 minutes.
    1. **HealthCheck** - Performs a health check of the health check service.

1. **Service.Tests** - Test project that includes the following types of tests:

    1. **Unit** - Tests designed to execute units of the code.  Includes all unit tests organized in a test class for each function or underlying service.  Tests are written using a behavior driven approach with each test representing a different scenario for executing a function or service.
    1. **Automated** - Tests designed to run against the functions exposed by the service while it is running.

1. **Pipeline** - Contains the following PowerShell scripts the execute the Eden standard pipeline actions:
    
    1. **Configure-Environment.ps1** - Sets environment variables used by the scripts to execute.  Includes the following environment variables.
            
        1. **InstanceName** - The name of the instance to deploy to in the Azure tenant.  Must be globally unique as it is used to name public resources created in Azure.  Also must be equal or less than 18 characters in length.
        1. **Region** - The Azure region to deploy into.
        1. **UserId** - The user name for the service principal to use for accessing Azure and performing deployments.
        1. **Password** - The password for the account/service principal to use for accessing Azure and performing deployments.
        1. **TenantId** - The unique id of the tenant that you should log into.
        1. **UniqueDeveloperId** - A unique string used to identify subscriptions deployed to event grid that are pointing at the developers local environment.
        1. **HealthLocalHostingPort** - The port address to use when hosting the function app locally.
    1. **Setup-LocalEnvironment** - Runs a modified pipeline to deploy the application to the specified cloud instance.  Then copies the app settings down to the local function application so that you can start and run the functions app locally and successfully connect to any needed cloud resources.
    1. **Show-Docs** - Displays the readme file (this file) in a new instance of VS Code.
    1. **Start-IDE** - Launches VS Code set to the Service folder.
    1. **Build-Appliction.ps1** - Compiles all projects in the service.  Uses the ContentReactor.Health.sln solution file to perform the build.  Can be set to run continuously by passing the `-Continuous` switch.
    1. **Test-Unit.ps1** - Executes the unit tests for the service.  Can be set to run continuously by passing the `-Continuous` switch.
    1. **Start-Local.ps1** - Launches the azure function apps locally.  
    
        Note:

        - `Setup-LocalEnvironment.ps1` - Prior to running the `Start-Local.ps1` script you must deploy a cloud instance and copy the application settings to your local function applications so that they can connect to the various Azure services (blobstorage, etc).  You can accomplish this by executing the `Setup-LocalEnvironment.ps1` script. 

    1. **Test-Automated** - Runs the automated tests against a local running instance of the service.  Runs the Start-Local script and then runs the automated tests.  Can be set to rerun the automated tests each time you save a code change in the test project using the `-Continuous` switch when calling the script.
    1. **Build-DeploymentPackage** - Publishes the function app to a `./dist` folder and then zips the published projects so that they are ready to deploy to Azure.
    1. **Deploy-Service** - Runs the scripts to fully deploy the service. This includes the Deploy-Infrastructre and Deploy-Application scripts.
    1. **Deploy-Infrastructure** - Deploys the Azure infrastructure for the service using the ARM templates defined in the infrastructure folder.  The `Infrastructure.json` file includes definitions of all resources.  See the Infrastructure section above for an explanation of the resources deployed.
    1. **Deploy-Applications** - Performs the following actions:

        1. **Staging Slot Deployment** - Deploys the API and Worker functions app to the staging slot.
        1. **Run Automated Tests** - Runs the automated tests against the staging slot instance of the applications in Azure.
        1. **Staging to Production Swap** - If the automated tests against the staging slot pass, the script swaps the staging and production slots.
    1. **Invoke-Pipeline** - Executes the full pipeline from end to end.  This includes:
        1. Build-Application.ps1
        1. Test-Unit.ps1
        1. Test-Automated.ps1
        1. Build-DeploymentPackage.ps1
        1. Deploy-Service.ps1

    