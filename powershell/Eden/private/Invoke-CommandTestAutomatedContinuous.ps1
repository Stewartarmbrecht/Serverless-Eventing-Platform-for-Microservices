
function Invoke-CommandTestAutomatedContinuous 
{
    [CmdletBinding()]
    param(
        [String]$SolutionName,
        [String]$ServiceName
    ) 
    dotnet watch --project ./../Service.Tests/$SolutionName.$ServiceName.Service.Tests.csproj `
        test --filter TestCategory=Automated    
    if ($LASTEXITCODE -ne 0) { throw "Running the unit tests exited with an error."}
}