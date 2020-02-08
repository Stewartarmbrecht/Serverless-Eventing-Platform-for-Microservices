# Developing

This solution has been designed to enable a full enterprise scale development flow.
This flow consists of the following feedback loops.  Under each feedback loop we 
have listed the issues that are checked and the technologies used to perform the checks
with links to resourcs to learn more about the technology.

* Coding Loop
    * [VS Code](https://code.visualstudio.com)
        * C# Compilation Issues - [Omnisharp](https://github.com/OmniSharp/omnisharp-vscode)
        * C# Code Commenting Issues - [Code Commenting](https://docs.microsoft.com/en-us/dotnet/csharp/codedoc) & [FxCop](https://www.nuget.org/packages/Microsoft.CodeAnalysis.FxCopAnalyzers/)
    * [Visual Studio 2017](https://www.microsoft.com/en-us/store/b/visualstudio)
        * C# Compilation Issues - [Omnisharp](https://github.com/OmniSharp/omnisharp-vscode)
        * C# Code Commenting Issues - [Code Commenting](https://docs.microsoft.com/en-us/dotnet/csharp/codedoc) & [FxCop](https://www.nuget.org/packages/Microsoft.CodeAnalysis.FxCopAnalyzers/)
        * C# Code Formatting Issues - [StyleCop](https://github.com/DotNetAnalyzers/StyleCopAnalyzers)
        * C# Code Structure Issues - [FxCop](https://www.nuget.org/packages/Microsoft.CodeAnalysis.FxCopAnalyzers/)
* Build Loop
    * [VS Code](https://code.visualstudio.com)
        * C# Code Formatting Issues - [StyleCop](https://github.com/DotNetAnalyzers/StyleCopAnalyzers)
        * C# Code Structure Issues - [FxCop](https://www.nuget.org/packages/Microsoft.CodeAnalysis.FxCopAnalyzers/)
        * C# Code Security Issues - [FxCop](https://www.nuget.org/packages/Microsoft.CodeAnalysis.FxCopAnalyzers/)
* Unit Testing Loop
* Isolated Run Loop
    * To run the web application with full functionality, execute the web/scripts/run-and-test.ps1 script.  You must have ngrok installed first.  It will do the following:
        * Launch the web server at https://localhost:5001 using dotnet run
        * Launch the web app at http://localhost:4200 using ng serve
        * Create a public address for the web server using ngrok
        * Deploy subscriptions to events published by the event grid for the client web server using web hooks to the ngrok public URL for the local dev server.
        * It also launches cypress.io testing tool so that you can run automated UI tests if you want to.
        * If you navigate to http://localhost:4200 you will have a fully functional running instance of the app connected to the azure proxy api and the events published by the azure event grid.  
        * Debug Web App - You can debug by attaching to the process running on http://localhost:4200.  
        * Debug Web Server - You can debug the web server by attaching to the process running on https://localhost:5001
* Continuous Integration Loop
* Automated Testing Loop
