# Eden Roadmap

Below is a list of features that are targeted for inclusion in the architecture:

1. **Health Checks** - Add health check system for monitoring, detection and notification of system stability, performance and resource utilization.
1. **Synthetics** - Setup system that performs critical user actions as a known user on a regular basis to enable monitoring for degredation in performance or detect stability issues.
1. **Local Integrated Testing** - Create scripts for each microservice that will launch a local instance of the service and connect it to cloud services for running integration and end to end tests.
1. **Local Event Routing** - Setup pattern for routing events to the local development instance only.  This should enable end to end testing and debugging of backend worker processes without having to deal with duplicate processing.
1. **Local Debugging** - Create VS Code task that launches and attaches to each microservice for debugging. Includes modifying the powershell launch script to return process ids so VS code can use the script to launch and then attach to the correct process for debugging.
1. **Local, Continuous Build and Testing** - Modify launch scripts to detect file changes and automatically build, unit test, and re-launch the target application.
1. **System Upgrade** - Upgrade all frameworks to the latest versions (Angular, .Net, Azure Functions, etc.).
1. **Azure DevOps Project** - Create script that sets up an Azure DevOps project for the solution.
1. **Automated Builds** - Modify the Azure DevOps project to detect code changes for a single microservice and automatically run the build process for just that microservice.
1. **Static Code Scans** - Add static code analysis to the build scripts for each microservice and fail the build process if exceptions are thrown.
1. **Automated Unit Testing** - Add unit testing to the build scripts for each microservice and fail the build process if exceptions are thrown.
1. **API End to End Testing** - Setup pattern for running end to end tests for each API microservice locally.
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
1. **Monitoring Alerts** - Modify application insights deployment to include defining thresholds and alerts.
1. **Exception Alerts** - Define alerts and notifications for application exceptions.
1. **Cost Alerts** - Define alerts and notifications based on cost thresholds.
1. **Governor Alerts** - Add alerts and notifications for violations of operation governors.
1. **IP Blacklisting** - Setup feature for automatically blacklisting certain IP addresses based on detection of malicious activity.
1. **User Lock-out** - Setup feature for locking out a user based on violated thresholds for user activity.