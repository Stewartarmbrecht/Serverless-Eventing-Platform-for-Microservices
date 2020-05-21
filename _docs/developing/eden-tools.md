## Setup

1. Install the dotnet eden tools...

        dotnet tool install --global dotnet-eden --version 0.0.1-alpha

2. Create a directory for your solution and open your terminal in that folder.
3. Initialize the solution...

        dotnet eden init

    1. Copies the default solution template into the current directory.
    2. Finds and replaces all references to the default solution name to match the parent folder name.

4. Add a microservice
    
        dotnet eden add service "My

5. Review the code to see how it works. If you have vscode installed...

        code .