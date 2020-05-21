function Build-Eden
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]  
        [String]$serviceName,
        [Parameter(Mandatory=$true)]  
        [String]$systemName
    )

    $loggingPrefix = "$systemName $serviceName Build"
    
    D "Building the '$serviceName' service." $loggingPrefix

    $directory = "./$serviceName"
    $result = dotnet build $directory

    Write-Verbose $result

    D "Finished building the '$serviceName' service." $loggingPrefix
}