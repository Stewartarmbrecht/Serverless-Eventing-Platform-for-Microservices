# Content Reactor - Audio Service
The Content Reactor audio service provides functionality for storing, transcribing, and retrieving audio files.

## Components
Below is an overview of what is included in the audio service by folder:

1. **Infrastructure** - Contains Azure Resource Manager templates:

    1. **infrastructure.json** - Deploys the following:

        1. **instance-audio-api** - Azure functions app service that provides the api of the service.
        1. **instance-audio-api/staging** - Azure functions app service slot that serves as the staging environment for api deployments.
        1. **instance-audio-worker** - Azure functions app service that executes functions in reponse to azure event grid events.
        1. **instance-audio-worker/staging** - Azure functions app service slot that serves as the staging environment for worker deployments.
        1. **instance-audio-asp** - Applicaiton service plan for hosting the 2 function apps and the 2 corresponding slots.
        1. **instanceaudiowebjobstorage** - Storage account used for information necessary to run the function apps.
        1. **instanceaudioblob** - Storage account used for all audio blobs managed by the service.
        1. **instanceaudiostagingblob** - Storage account used for all audio blobs managed by the service.
        1. **instance-audio-cs** - Cognitive Services speeach account used for transcribing audio files.
        1. **instance-audio-ai** - Applicaiton Insights instance that provides monitoring for all components in the service.

    2. **subscriptions.json** - Deploys the subscriptions to the following Azure Event Grid events:

        1. **AudioCreated** - Raised by the audio api when a new audio file has been successfully uploaded to the service.

1. **API** - C# Azure Function project. Includes the following functions:

    1. **AddBegin** - Called to get a url to upload a new audio file.
    1. **AddComplete** - Called to signal that a new audio file has been uploaded to the url provided by the AddBegin function.  Raises the AudioCreated event.
    1. **Get** - Gets the details of a single audio file.  Includes a url to download the audio file that is accessible for 1 hour.
    1. **GetList** - Gets a list of all audio files for single user.  Includes just the id and transcript preview.
    1. **Delete** - Deletes an audio file from the service.
    1. **HealthCheck** - Performs a health check to ensure the services has access to all the resources it needs to operate effectively.

1. **Worker** - C# Azure Function project.  Includes the following functions:

    1. **UpdateTranscript** - Responds to the AudioCreated event.  Uses the Cognitive Services Speech api to get a transcript for the audio file.
    1. **HealthCheck** - Performs a health check to ensure the services has access to all the resources it needs to operate effectively.

    This project also includes the following service:

    1. **AudioTranscription** - Uses the Cognitive Services Speech API to get the transcription of an audio file.

    Functions represent the external operations exposed by the applications.  Services are the internal operations used by the application to access functions of other applications.

1. **Tests** - Test project that includes the following types of tests:

    1. **Unit** - Tests designed to execute units of the code.  Includes all unit tests organized in a test class for each function or underlying service.  Tests are written using a behavior driven approach with each test representing a different scenario for executing a function or service.
    1. **Automated** - Tests designed to run against the functions exposed by the service while it is running.

1. **Pipeline** - Contains the following PowerShell scripts the execute the Eden standard pipeline actions:
    
    1. **Configure-Environment.ps1** - Sets environment variables used by the scripts to execute.  Includes the following environment variables.
            
        1. **InstanceName** - The name of the instance to deploy to in the Azure tenant.  Must be globally unique as it is used to name public resources created in Azure.
        1. **Region** - The Azure region to deploy into.
        1. **UserName** - The user name for the service principal to use for accessing Azure and performing deployments.
        1. **Password** - The password for the account/service principal to use for accessing Azure and performing deployments.
        1. **TenantId** - The unique id of the tenant that you should log into.
        1. **UniqueDeveloperId** - A unique string used to identify subscriptions deployed to event grid that are pointing at the developers local environment.
        1. **ApiPort** - The port address to use when running the Api functions app locally.
        1. **WorkerPort** - The port address to use when running the Worker functions app locally.
        
    1. **Build-Applictions.ps1** - Compiles all projects in the service.  Uses the ContentReactor.Audio.Service.sln solution file to perform the build.
    1. **Test-Unit.ps1** - Executes the unit tests for the service.  Can be set to run continuously by passing the `-Continuous` switch.
    1. **Start-Service.ps1** - Launches the azure function apps locally and connects the worker function app to the event grid for a target instance of the system in a specific azure tenant.  It deploys a developer specific subscription to the AudioCreated event using a service principal in the azure tenant. 
    
        Note:

        - `Deploy-Infrastucture.ps1` - Prior to running the `Start-Service.ps1` script you must deploy the event grid topic and audio service infrastructure to Azure using the `Deploy-Infrastucture.ps1` script in the `/events/pipeline` and `/audio/pipeline` folders.

        - `Setup-LocalEnvironment.ps1` - Once you have deployed the infrastructure, you must copy the application settings to your local function applications so that they can connect to the various Azure services (blobstorage, event grid, cognitive services, etc) prior to running the service locally.  You can accomplish this by executing the `Setup-LocalEnvironment.ps1` script. 

    1. **Test-Automated** - Runs the automated tests against a local running instance of the service.  Runs the Start-Service script and then runs the automated tests.  Can be set to rerun the automated tests each time you save a code change in the test project using the `-Continuous` switch when calling the script.
    1. **Build-DeploymentPackages** - Publishes the function apps to a `./distr` folder and then zips the published projects so that they are ready to deploy to Azure.
    1. **Deploy-Infrastructure** - Deploys the Azure infrastructure for the service using the ARM templates defined in the infrastructure folder.  The `service.json` file includes definitions of all resources.  The `subscriptions.json` includes the event grid subscriptions for the worker application.  See the Infrastructure section above for an explanation of the resources deployed.
    1. **Deploy-Applications** - Performs the following actions:

        1. **Staging Slot Deployment** - Deploys the API and Worker functions app to the staging slot.
        1. **Run Automated Tests** - Runs the automated tests against the staging slot instance of the applications in Azure.
        1. **Staging to Production Swap** - If the automated tests against the staging slot pass, the script swaps the staging and production slots.
    
    1. **Deploy-Subscriptions** - Need to finish...