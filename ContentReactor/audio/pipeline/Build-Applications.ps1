[CmdletBinding()]
param(
    [switch]$Continuous
)

$currentDirectory = Get-Location
Set-Location $PSScriptRoot

. ./Functions.ps1

$loggingPrefix = "ContentReactor Audio Build"

try {
    #Set-Location "./../"
    if ($Continuous) {
        $command = "dotnet watch --project ./../ContentReactor.Audio.sln build ./ContentReactor.Audio.sln"
    } else {
        $command = "dotnet build ./../ContentReactor.Audio.sln"
    }
    
    Invoke-BuildCommand $command $loggingPrefix "Building the solution."    

    Set-Location $PSScriptRoot
} catch {
    Set-Location $PSScriptRoot
}



Write-BuildInfo "Finished building the solution." $loggingPrefix

Set-Location $currentDirectory
