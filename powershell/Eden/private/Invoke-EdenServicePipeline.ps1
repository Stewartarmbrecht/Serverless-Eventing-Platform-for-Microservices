function Invoke-EdenServicePipeline
{
    [CmdletBinding()]
    param( 
        [Parameter(Mandatory=$true)]
        [String]$serviceName,
        [Parameter(Mandatory=$true)]
        [String]$solutionName,
        [Parameter(Mandatory=$true)]
        [String]$systemName,
        [Int]$port
    )

    $loggingPrefix = "$systemName $serviceName Pipeline Service"
    
    D "Running the full pipeline for the '$serviceName' service." $loggingPrefix
    
    Build-EdenService -serviceName $serviceName -systemName $systemName
    Test-EdenService -v $verbosity
    ./run.ps1 -t $TRUE -v $verbosity
    ./package.ps1 -v $verbosity
    ./deploy.ps1 -v $verbosity
    
    D "Finished the full pipeline for the '$serviceName' service." $loggingPrefix
    
}
