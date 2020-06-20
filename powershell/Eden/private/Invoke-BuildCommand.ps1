function Invoke-BuildCommand 
{
    [CmdletBinding()]
    param(
        [String]$SolutionName,
        [String]$ServiceName
    ) 
    dotnet build ./$SolutionName.$ServiceName.sln | Write-Verbose
    if ($LASTEXITCODE -ne 0) { throw "Building the solution exited with an error."}
}