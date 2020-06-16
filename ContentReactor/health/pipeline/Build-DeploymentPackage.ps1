[CmdletBinding()]
param(  
)

$solutionName = "ContentReactor"
$serviceName = "Health"

try {
    $currentDirectory = Get-Location
    Set-Location $PSScriptRoot
    
    . ./Functions.ps1
    
    $loggingPrefix = "$solutionName $serviceName Package"
    
    Set-Location "$PSSCriptRoot/../"
    
    $directoryStart = Get-Location
    
    Write-BuildInfo "Packaging the service application." $loggingPrefix
    
    Set-Location "$directoryStart/Service"
    Invoke-BuildCommand "dotnet publish -c Release -o $directoryStart/.dist/app" "Publishing the function application." $loggingPrefix
    
    $appPath =  "$directoryStart/.dist/app/**"
    $appDestination = "$directoryStart/.dist/app.zip"
    
    Write-BuildInfo "Removing the app package." $loggingPrefix
    Remove-Item -Path $appDestination -Recurse -Force -ErrorAction Ignore
    
    Write-BuildInfo "Creating the app package." $loggingPrefix
    Compress-Archive -Path $appPath -DestinationPath $appDestination
    
    Write-BuildInfo "Packaged the service." $loggingPrefix
    Set-Location $currentDirectory
}
catch {
    Set-Location $currentDirectory
    throw $_    
}
