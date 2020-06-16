[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]  
    [String]$systemName,
    [Parameter(Mandatory=$true)]  
    [String]$instanceName,
    [Parameter(Mandatory=$true)]  
    [String]$serviceName
)

$loggingPrefix = "$systemName $instanceName $serviceName Build"

D "Building the service." $loggingPrefix

$result = dotnet build

Write-Verbose $result

D "Finished building the service." $loggingPrefix