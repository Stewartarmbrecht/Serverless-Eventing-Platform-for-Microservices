function Build-EdenServiceApp
{
    [CmdletBinding()]
    param(
        [switch]$Continuous
    )
    
    try {
        
        $currentDirectory = Get-Location

        $solutionName = ($currentDirectory -split '\\')[-2]
        $serviceName = ($currentDirectory -split '\\')[-1]

        $loggingPrefix = "$solutionName $serviceName Build"
        
        Write-BuildInfo $currentDirectory $loggingPrefix

        Write-BuildInfo $location $loggingPrefix
        
        if ($Continuous) {
            Write-BuildInfo "Building the solution continuously." $loggingPrefix
            dotnet watch --project ./$solutionName.$serviceName.sln build ./$solutionName.$serviceName.sln | Write-Verbose
            if ($LASTEXITCODE -ne 0) { throw "Building the solution exited with an error."}
        } else {
            Write-BuildInfo "Building the solution." $loggingPrefix
            dotnet build ./$solutionName.$serviceName.sln | Write-Verbose
            if ($LASTEXITCODE -ne 0) { throw "Building the solution exited with an error."}
        }
        
        Write-BuildInfo "Finished building the solution." $loggingPrefix
    
        Set-Location $currentDirectory
    }
    catch
    {
        Set-Location $currentDirectory
        throw $_
    }
}
