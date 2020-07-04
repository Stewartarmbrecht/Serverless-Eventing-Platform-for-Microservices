function Invoke-CommandTestAutomated
{
    [CmdletBinding()]
    param(
        [EdenEnvConfig]$EdenEnvConfig
    ) 
    dotnet test ./../Service.Tests/$($EdenEnvConfig.SolutionName).$($EdenEnvConfig.ServiceName).Service.Tests.csproj `
        --filter TestCategory=Automated
    if ($LASTEXITCODE -ne 0) { throw "Running the unit tests exited with an error."}
}