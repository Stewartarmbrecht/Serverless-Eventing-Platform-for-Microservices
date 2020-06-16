[CmdletBinding()]
param()

$solutionName = "ContentReactor"
$serviceName = "Health"

try {
    $currentDirectory = Get-Location
    Set-Location $PSScriptRoot

    . ./Functions.ps1

    ./Configure-Environment.ps1 -Check

    $instanceName = $Env:InstanceName

    $loggingPrefix = "$solutionName $serviceName Deploy Service $instanceName"

    Write-BuildInfo "Deploying the service." $loggingPrefix

    ./Deploy-Infrastructure.ps1

    ./Deploy-Application.ps1

    #./Deploy-Subscription.ps1

    Write-BuildInfo "Deployed the service." $loggingPrefix

    Set-Location $currentDirectory
}
catch {
    Set-Location $currentDirectory
    throw $_    
}
