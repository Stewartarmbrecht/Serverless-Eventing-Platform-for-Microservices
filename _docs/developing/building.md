# Building

_Execute [the setup instructions](setup.md) prior to 
building the solution._

The following commands can be used to build different aspects of the system.

| Action | Script | VS Code Task |
| ------ | ------ | ------------ |
| Build, test, package and deploy the entire system | `./scripts/buildanddeploy.ps1 `<br>` -namePrefix {your-globally-unique-name-prefix} `<br>`-region westus2 `<br>`-bigHugeThesaurusApiKey {your-api-key}` | `system-pipeline` |
| Build, test, package and deploy a microservice's applications and infrastructure | `./{microservice}/scripts/deploy.ps1 `<br>`-namePrefix {your-globally-unique-name-prefix} `<br>`-region westus2 `<br>`-bigHugeThesaurusApiKey {your-api-key}` | `{microservice}-pipeline` |
| Build, test, package and deploy a microservice's applications | `./{microservice}/scripts/deploy-apps.ps1 `<br>`-namePrefix {your-globally-unique-name-prefix} `<br>`-region westus2 `<br>`-bigHugeThesaurusApiKey {your-api-key}` | `{microservice}-apps-pipeline` |
| Build and test a microservice's applications | `./{microservice}/scripts/test.ps1` | `{microservice}-test` |
| Build, test, and debug a microservice's applications | NA | `{microservice}-debug` |
| Build a microservice's applications | `./{microservice}/scripts/build.ps1` | `{microservice}-build` |

