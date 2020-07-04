
function Invoke-CommandTestAutomatedContinuous 
{
    [CmdletBinding()]
    param(
        [EdenEnvConfig]$EdenEnvConfig
    ) 
    dotnet watch `
        --project ./../Service.Tests/$($EdenEnvConfig.SolutionName).$($EdenEnvConfig.ServiceName).Service.Tests.csproj `
        test --filter TestCategory=Automated    
    if ($LASTEXITCODE -ne 0) { throw "Running the unit tests exited with an error."}
}