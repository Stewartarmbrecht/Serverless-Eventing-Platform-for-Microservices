# Eden Roadmap

Below is a list of features that are targeted for inclusion in the architecture:

* **Health Checks** - Add health check system for monitoring, detection and notification of system stability, performance and resource utilization.
* **Synthetics** - Setup system that performs critical user actions as a known user on a regular basis to enable monitoring for degredation in performance or detect stability issues.
* **Local Integrated Testing** - Create scripts for each microservice that will launch a local instance of the service and connect it to cloud services for running integration and end to end tests.
* **Local Event Routing** - Setup pattern for routing events to the local development instance only.  This should enable end to end testing and debugging of backend worker processes without having to deal with duplicate processing.
* **Local Debugging** - Create VS Code task that launches and attaches to each microservice for debugging. Includes modifying the powershell launch script to return process ids so VS code can use the script to launch and then attach to the correct process for debugging.
* **Local, Continuous Build and Testing** - Modify launch scripts to detect file changes and automatically build, unit test, and re-launch the target application.
* **System Upgrade** - Upgrade all frameworks to the latest versions (Angular, .Net, Azure Functions, etc.).
* **Azure DevOps Project** - Create script that sets up an Azure DevOps project for the solution.
* **Automated Builds** - Modify the Azure DevOps project to detect code changes for a single microservice and automatically run the build process for just that microservice.
* **Static Code Scans** - Add static code analysis to the build scripts for each microservice and fail the build process if exceptions are thrown.
* **Automated Unit Testing** - Add unit testing to the build scripts for each microservice and fail the build process if exceptions are thrown.
* **API End to End Testing** - Setup pattern for running end to end tests for each API microservice locally.
* **Automated End to End Testing** - Add test script that runs all end to end tests for a microservice or the entire solution.
* **Code Coverage Analysis** - Add code coverage analysis to the build scripts and fail the build process if exceptions are thrown.
* **Automated Code Deployments** - Modify the Azure DevOps project to run the deployment scripts (which include blue green deployments) for a single microservice after the microservice runs a success build and test triggered by a code change.
* **Blue Green Deployments** - Modify deployment scripts to use deployment slots, warm the application up, validate the health and then toggle slots for code deployments.  The scripts should prevent the deployment if the health checks and synthetics detect any issues.
* **Feature Toggling** - Create pattern for using feature toggling to enable and disable new features that have been deployed to an application.
* **Rolling Deployments** - Create system for rolling out and rolling back new features across the user base that leverages feature toggling and health checks.
* **System Governors** - Enable governors that monitor and block user activity and IP activity that exceeds predefined thresholds to protect against cost overruns.
* **Circuit Breakers** - Enable the detection and graceful handling of partial system outages.
* **Authentication** - Implement a real user authentication system that maintains the simplified deployment model for new deployments.
* **Authorization** - Define pattern for authorizing operations.
* **Monitoring Alerts** - Modify application insights deployment to include defining thresholds and alerts.
* **Exception Alerts** - Define alerts and notifications for application exceptions.
* **Cost Alerts** - Define alerts and notifications based on cost thresholds.
* **Governor Alerts** - Add alerts and notifications for violations of operation governors.
* **IP Blacklisting** - Setup feature for automatically blacklisting certain IP addresses based on detection of malicious activity.
* **User Lock-out** - Setup feature for locking out a user based on violated thresholds for user activity.
