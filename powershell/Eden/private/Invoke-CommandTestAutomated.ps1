function Invoke-CommandTestAutomated
{
    [CmdletBinding()]
    param(
        [String]$SolutionName,
        [String]$ServiceName
    ) 
    dotnet test ./../Service.Tests/$SolutionName.$ServiceName.Service.Tests.csproj `
        --filter TestCategory=Automated
    if ($LASTEXITCODE -ne 0) { throw "Running the unit tests exited with an error."}
}