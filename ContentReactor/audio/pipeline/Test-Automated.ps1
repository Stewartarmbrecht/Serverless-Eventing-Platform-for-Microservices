[CmdletBinding()]
param(
    [Parameter()]
    [switch]$Continuous
)

$currentDirectory = Get-Location
Set-Location $PSScriptRoot

$loggingPrefix = "ContentReactor Audio Test End to End $instanceName"

if ($Continuous) {
    Write-BuildInfo "Running automated tests continuously." $loggingPrefix
    ./Start-Service.ps1 -RunAutomatedTestsContinuously -Verbose
} else {
    Write-BuildInfo "Running automated tests." $loggingPrefix
    ./Start-Service.ps1 -RunAutomatedTests
}

Set-Location $currentDirectory
