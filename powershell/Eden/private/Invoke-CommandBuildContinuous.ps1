function Invoke-CommandBuildContinuous 
{
    [CmdletBinding()]
    param(
        [String]$SolutionName,
        [String]$ServiceName
    ) 
    dotnet watch --project ./$SolutionName.$ServiceName.sln build ./$SolutionName.$ServiceName.sln | Write-Verbose
    if ($LASTEXITCODE -ne 0) { throw "Building the solution exited with an error."}
}