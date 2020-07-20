[CmdletBinding()]
param(
    [Parameter()]
    [switch]$Continuous
)

$solutionName = "ContentReactor"
$serviceName = "Health"

try
{
    $currentDirectory = Get-Location
    Set-Location $PSScriptRoot

    . ./Functions.ps1

    ./Configure-Environment -Check

    $instanceName = $Env:InstanceName

    $loggingPrefix = "$solutionName $serviceName Test End to End $instanceName"

    if ($Continuous) {
        Write-EdenBuildInfo "Running automated tests continuously." $loggingPrefix
        ./Start-Local.ps1 -RunAutomatedTestsContinuously -Verbose
    } else {
        Write-EdenBuildInfo "Running automated tests." $loggingPrefix
        ./Start-Local.ps1 -RunAutomatedTests
    }

    Set-Location $currentDirectory
}
catch
{
    Set-Location $currentDirectory
    throw $_
}