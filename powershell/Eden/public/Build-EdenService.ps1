function Build-EdenService
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
            Write-BuildInfo "Building the service continuously." $loggingPrefix
            Invoke-CommandBuildContinuous -SolutionName $solutionName -ServiceName $serviceName 
        } else {
            Write-BuildInfo "Building the service." $loggingPrefix
            Invoke-CommandBuild -SolutionName $solutionName -ServiceName $serviceName 
            Write-BuildInfo "Finished building the service." $loggingPrefix
        }
        
    }
    catch
    {
        Write-BuildError "Error building the service. Message: '$($_.Exception.Message)'" $loggingPrefix
        throw $_
    }
}
