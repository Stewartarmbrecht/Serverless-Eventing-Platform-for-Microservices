[CmdletBinding()]
param(
)

$currentDirectory = Get-Location
Set-Location $PSScriptRoot

. ./Functions.ps1

$loggingPrefix = "ContentReactor Api Package"

$path =  "./../application/**"
$destination = "./../.dist/app.zip"

Write-BuildInfo "Removing the API package." $loggingPrefix 
Remove-Item -Path $destination -Recurse -Force -ErrorAction Ignore

Write-BuildInfo "Creating the .dist folder." $loggingPrefix
$result = New-Item -Path "./../" -Name ".dist" -ItemType "directory" -Force
if($VerbosePreference -ne 'SilentlyContinue') { $result }

Write-BuildInfo "Creating the API package." $loggingPrefix
Compress-Archive -Path $path -DestinationPath $destination 

Write-BuildInfo "Finished building the Api package." $loggingPrefix

Set-Location $currentDirectory
