---
services: functions, event-grid, cosmos-db
platforms: dotnet
author: nzthiago
---

# Content Reactor: Serverless Microservice Sample for Azure

In this sample, we have built four microservices that use an [Event Grid](https://docs.microsoft.com/en-us/azure/event-grid/overview) custom topic for inter-service eventing, and a front-end Angular.js app that uses [SignalR](https://www.asp.net/signalr) to forward Event Grid events to the user interface in real time.

This sample includes detailed documentation for explaining
all aspects of the system architecture as well as the processes you should use to develop the solution in either a start-up or enterprise enterprise environment.

* **Overview**
    * [Functionality](/_docs/overview/functionality.md)
    * [Architecture Overview](/_docs/overview/functionality.md)

* **Developing**
    * [Setup](/_docs/developing/setup.md)
    * [Building](/_docs/developing/building.md)
    * [Debugging](/_docs/developing/debugging.md)
    * [Deploying](/_docs/developing/deploying.md)

* **Releasing**
    * [Continuous Integration](/_docs/releasing/continuous-integration.md)
    * [Continuous Deployment](/_docs/releasing/continuous-deployment.md)

* **Monitoring**
    * [Health Checks](/_docs/monitoring/health-checks.md)
    * [Application Monitoring](/_docs/monitoring/application-monitoring.md)
    * [End User Monitoring](/_docs/monitoring/end-user-monitoring.md)
    * [Alerting](/_docs/monitoring/alerting.md)
    * [Troubleshooting](/_docs/monitoring/troubleshooting.md)

