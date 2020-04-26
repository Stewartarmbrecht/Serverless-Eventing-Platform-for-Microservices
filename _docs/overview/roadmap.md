# Eden Roadmap

Below is the list of features currently packed into the solution.

1. **Single Command, Full System Deployment** - You can deploy the entire solution to the cloud with a single command.
1. **Independent Microservice Deployment** - You can deploy each microserivce with a single command.
1. **Cross Platform Development** - You can build, run, and test on Windows, Mac, or Linux (designed for but not tested on all).
1. **Single Command Build and Test** - You can build and run the unit tests with a single command.
1. **Automated Unit Testing** - Each microservice has a test project to create and run automated unit tests.
1. **Automated UI E2E Testing** - Uses cypress.io to develop and execute end to end tests for the UI.
1. **Automated API E2E Testing** - Uses cypress.io to develop and execute end to end tests for the API.
1. **Local Build and Run** - You can build and run each microservice locally and connected to the full system in Azure.
1. **Local End to End Testing** - You can locally run and debug a microservice using end to end tests.
1. **Integrated Documentation** - The system documentation is part of the code base and under version control.
1. **Integrated Monitoring** - Every component and microservice is instrumented with application insights for monitoring.
1. **Health Checks** - Add health check system for monitoring, detection and notification of system stability, performance and resource utilization.
1. **Enforced Code Commenting** - Leveragess Microsoft.CodeAnalysis.FxCopAnalyzers to enforce code commenting.
1. **Enforced Code Formating** - Leverages StyleCop.Analyzers to enforce code formatting.
1. **Secure Code Static Analysis** - Uses SecurityCodeScan to scan code for security issues.
1. **Artificial Intelligence** - The solution leverages artificial intelligence services.

Below is a list of features that are targeted for inclusion in the architecture:

1. **Latest Components** - All code leverages the latests generally available components (like Azure Functions 3.0, .Net Core 3.1 etc.).
1. **Fully Commented Code** - All code is fully commented.
1. **Fully Compliant Code** - All analyzer warnings are handled.
1. **Dependency Injection** - Demonstrates how to use dependency injection in Azure Functions.  Reading [here](https://docs.microsoft.com/en-us/azure/azure-functions/functions-dotnet-dependency-injection).
1. **Validation Pattern** - Demonstrates best practices for handling function input validation.
1. **Safe, Continuous Upgrades** - Defined pattern for upgrading projects independently.  Specifically enables upgrading shared components without requiring upgrades to all dependent projects leveraging private nuget feeds. Possible answer [here](https://newsignature.com/articles/want-to-host-your-private-nuget-feed-use-azure-devops/).
1. **Exception Handling** - Demonstrates best practices for handling exceptions.  Reading [here](https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-error-pages).
1. **Retry Pattern** - Demonstrates how to leverage Poly for implementing retry policies for service calls. Reading [here[](https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-error-pages).
1. **Circuit Breaker Pattern** - Demonstrates how to implement circuit breakers with Event Grid and Azure functions.
1. **Idempotent Operations** - Demonstrates how to implement idemptoment Azure Fuction operations.
1. **Blob Handling Pattern** - Demonstrates how to handle blob storage using shared access storage tokens.
1. **Multi-linqual Support** - All static strings are stored in resource files and translated.  All culture specific operations are handled in the users culture.
1. **File Watching Restarts** - Change the build and run scripts to watch for file changes and relaunch the application.
1. **Local Debugging** - Create VS Code task that launches and attaches to each microservice for debugging. Includes modifying the powershell launch script to return process ids so VS code can use the script to launch and then attach to the correct process for debugging.
1. **Single Command Setup** - Create a powershell script that installs all prerequisites for downloading, building, testing, and deploying the solution.
1. **Synthetics** - Setup system that performs critical user actions as a known user on a regular basis to enable monitoring for degredation in performance or detect stability issues.
1. **Local Event Routing** - Setup pattern for routing events to the local development instance only.  This should enable end to end testing and debugging of backend worker processes without having to deal with duplicate processing.
1. **Local, Continuous Build and Testing** - Modify launch scripts to detect file changes and automatically build, unit test, and re-launch the target application.
1. **System Upgrade** - Upgrade all frameworks to the latest versions (Angular, .Net, Azure Functions, etc.).
1. **Azure DevOps Project** - Create script that sets up an Azure DevOps project for the solution.
1. **Automated Builds** - Modify the Azure DevOps project to detect code changes for a single microservice and automatically run the build process for just that microservice.
1. **Automated End to End Testing** - Add test script that runs all end to end tests for a microservice or the entire solution.
1. **Code Coverage Analysis** - Add code coverage analysis to the build scripts and fail the build process if exceptions are thrown.
1. **Automated Code Deployments** - Modify the Azure DevOps project to run the deployment scripts (which include blue green deployments) for a single microservice after the microservice runs a success build and test triggered by a code change.
1. **Blue Green Deployments** - Modify deployment scripts to use deployment slots, warm the application up, validate the health and then toggle slots for code deployments.  The scripts should prevent the deployment if the health checks and synthetics detect any issues.
1. **Feature Toggling** - Create pattern for using feature toggling to enable and disable new features that have been deployed to an application.
1. **Rolling Deployments** - Create system for rolling out and rolling back new features across the user base that leverages feature toggling and health checks.
1. **System Governors** - Enable governors that monitor and block user activity and IP activity that exceeds predefined thresholds to protect against cost overruns.
1. **Circuit Breakers** - Enable the detection and graceful handling of partial system outages.
1. **Authentication** - Implement a real user authentication system that maintains the simplified deployment model for new deployments.
1. **Authorization** - Define pattern for authorizing operations.
1. **Key Vault** - Modify so that microservices use a common key vault to store all secrets.
1. **Monitoring Alerts** - Modify application insights deployment to include defining thresholds and alerts.
1. **Exception Alerts** - Define alerts and notifications for application exceptions.
1. **Cost Alerts** - Define alerts and notifications based on cost thresholds.
1. **Governor Alerts** - Add alerts and notifications for violations of operation governors.
1. **IP Blacklisting** - Setup feature for automatically blacklisting certain IP addresses based on detection of malicious activity.
1. **User Lock-out** - Setup feature for locking out a user based on violated thresholds for user activity.
1. **Performance Testing** - Includes projects for developing and running performance testing.
