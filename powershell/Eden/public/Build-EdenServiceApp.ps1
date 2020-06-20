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
        
        Write-BuildInfo $location $loggingPrefix
        
        if ($Continuous) {
            Write-BuildInfo "Building the solution continuously." $loggingPrefix
            Invoke-ContinuousBuildCommand -SolutionName $solutionName -ServiceName $serviceName 
        } else {
            Write-BuildInfo "Building the solution." $loggingPrefix
            Invoke-BuildCommand -SolutionName $solutionName -ServiceName $serviceName 
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
