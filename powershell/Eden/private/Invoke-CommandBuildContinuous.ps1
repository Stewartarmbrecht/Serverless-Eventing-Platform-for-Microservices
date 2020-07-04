function Invoke-CommandBuildContinuous 
{
    [CmdletBinding()]
    param(
        [EdenEnvConfig]$EdenEnvConfig
    ) 
    dotnet watch --project ./$($EdenEnvConfig.SolutionName).$($EdenEnvConfig.ServiceName).sln `
        build ./$($EdenEnvConfig.SolutionName).$($EdenEnvConfig.ServiceName).sln | Write-Verbose
    if ($LASTEXITCODE -ne 0) { throw "Building the solution exited with an error."}
}