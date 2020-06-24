function Build-EdenServiceApp
{
    [CmdletBinding()]
    param(
        [switch]$Continuous
    )
    
    try {
        
        $solutionName = Get-SolutionName
        $serviceName = Get-ServiceName

        $loggingPrefix = "$solutionName $serviceName Build"
        
        Write-BuildInfo $location $loggingPrefix
        
        if ($Continuous) {
            Write-BuildInfo "Building the solution continuously." $loggingPrefix
            Invoke-CommandBuildContinuous -SolutionName $solutionName -ServiceName $serviceName 
        } else {
            Write-BuildInfo "Building the solution." $loggingPrefix
            Invoke-CommandBuild -SolutionName $solutionName -ServiceName $serviceName 
        }
        
        Write-BuildInfo "Finished building the solution." $loggingPrefix
    }
    catch
    {
        throw $_
    }
}
