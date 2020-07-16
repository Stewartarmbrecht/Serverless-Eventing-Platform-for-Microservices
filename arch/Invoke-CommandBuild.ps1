function Invoke-CommandBuild 
{
    [CmdletBinding()]
    param(
        [EdenEnvConfig]$EdenEnvConfig
    ) 
    dotnet build ./$($EdenEnvConfig.SolutionName).$($EdenEnvConfig.ServiceName).sln | Write-Verbose
    if ($LASTEXITCODE -ne 0) { throw "Building the solution exited with an error."}
}