[CmdletBinding()]
param(
    [Parameter()]
    [switch]$Continuous
)

$currentDirectory = Get-Location
Set-Location $PSScriptRoot

$loggingPrefix = "ContentReactor Audio Test End to End $instanceName"

if ($Continuous) {
    Write-BuildInfo "Running end to end tests continuously." $loggingPrefix
    ./Start-Service.ps1 -RunEndToEndTestsContinuously -Verbose
} else {
    Write-BuildInfo "Running end to end tests." $loggingPrefix
    ./Start-Service.ps1 -RunEndToEndTests
}

Set-Location $currentDirectory
