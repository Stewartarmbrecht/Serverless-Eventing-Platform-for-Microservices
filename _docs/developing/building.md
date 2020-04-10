# Building

_Execute [the setup instructions](setup.md) prior to 
building the solution._

The following commands can be used to build different aspects of the system.

To simplify the VS Code Tasks you need to use the workspace settings.json
file to set certain environment variables for the PowerShell scripts called
by the VS Code tasks.  Add the following section to your `settings.json` file
in the `.vscode` in the root of the repo.

    {
        "terminal.integrated.env.windows": {
            "systemName": "{your-globally-unique-name-prefix}",
            "region": "westus2",
            "bigHugeThesaurusApiKey": "{your-api-key}"
        }
    }



| Action | Script | VS Code Task |
| ------ | ------ | ------------ |
| Build, test, package and deploy the entire system | `./scripts/buildanddeploy.ps1 `<br>` -systemName {your-globally-unique-name-prefix} `<br>`-region westus2 `<br>`-bigHugeThesaurusApiKey {your-api-key}` | `system-pipeline` |
| Build, test, package and deploy a microservice's applications and infrastructure | `./{microservice}/scripts/deploy.ps1 `<br>`-systemName {your-globally-unique-name-prefix} `<br>`-region westus2 `<br>`-bigHugeThesaurusApiKey {your-api-key}` | `{microservice}-pipeline` |
| Build, test, package and deploy a microservice's applications | `./{microservice}/scripts/deploy-apps.ps1 `<br>`-systemName {your-globally-unique-name-prefix} `<br>`-region westus2 `<br>`-bigHugeThesaurusApiKey {your-api-key}` | `{microservice}-apps-pipeline` |
| Build and test a microservice's applications | `./{microservice}/scripts/test.ps1` | `{microservice}-test` |
| Build a microservice's applications | `./{microservice}/scripts/build.ps1` | `{microservice}-build` |
| Debug a unit test | NA | [See this.](./debugging.md) |

