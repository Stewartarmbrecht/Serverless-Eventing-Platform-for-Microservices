*This is just a scratch document for now*

## Ubuntu

1. [Install .Net Core SDK](https://www.microsoft.com/net/download/linux-package-manager/ubuntu16-04/sdk-2.1.300)
2. [Install Node](https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions)
3. Install Core Tools

        npm install -g azure-functions-core-tools@core

4. [Install Angular CLI](https://cli.angular.io/)
5. Add `local.settings.json` file with the following content:

        {
            "IsEncrypted": false,
            "Values": {
                "AzureWebJobsStorage": "<connection-string>",
                "AzureWebJobsDashboard": "<connection-string>",
                "MyBindingConnection": "<binding-connection-string>"
            },
            "Host": {
                "LocalHttpPort": 7071,
                "CORS": "*"
            },
            "ConnectionStrings": {
                "SQLConnectionString": "<sqlclient-connection-string>"
            }
        }
6. Install the [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/).

## Resouces
* [Work with Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local)
* [Code and test Azure Functions locally](https://docs.microsoft.com/en-us/azure/azure-functions/functions-develop-local)