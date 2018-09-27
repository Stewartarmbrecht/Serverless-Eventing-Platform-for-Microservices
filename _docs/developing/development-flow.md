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
* Continuous Integration Loop
* Automated Testing Loop
