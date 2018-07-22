# Functionality

## Overview

The application itself is a personal knowledge management system, and it allows users to upload text, images, and audio for these to be placed into categories. Each of these types of data is managed by a dedicated microservice built on Azure serverless technologies including [Azure Functions](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview) and [Cognitive Services](https://docs.microsoft.com/en-us/azure/cognitive-services/welcome). The web front-end communicates with the microservices through a SignalR-to-Event Grid bridge, allowing for real-time reactive UI updates based on the microservice updates. Each microservice is built and deployed independently using VSTS’s build and release management system, and use a variety of Azure-native data storage technologies.

## UI Screenshots

Here are some sample screenshots from the front end that covers all scenarios and most screens.



### Login Screen

![Screen 1](/_docs/_images/screen1.png)



### Category CRUD screens

#### Category Create

![Screen 3](/_docs/_images/screen3.png)

#### Category Image/Synonym Update Event

![Screen 4](/_docs/_images/screen4.png)

#### Category Name Update and Image change notification

![Screen 5](/_docs/_images/screen5.png)



### Image CRUD and notification screens

#### Image Create

![Screen 6](/_docs/_images/screen6.png)

#### Image Caption Updated through Event Grid notification 

![Screen 7](/_docs/_images/screen7.png)

![Screen 11](/_docs/_images/screen11.png)


### Text CRUD and notification screens

#### Text Note create

![Screen 8](/_docs/_images/screen8.png)

#### Text Note show

![Screen 10](/_docs/_images/screen10.png)



### Audio CRUD and notification screens

#### Audio create

![Screen 12](/_docs/_images/screen12.png)

#### Audio processing

![Screen 13](/_docs/_images/screen13.png)

#### Audio transcript event grid notification

![Screen 14](/_docs/_images/screen14.png)

#### Audio show 

![Screen 15](/_docs/_images/screen15.png)



### Events at category level

Events are displayed as notifications against a category.

![Screen 16](/_docs/_images/screen16.png)

