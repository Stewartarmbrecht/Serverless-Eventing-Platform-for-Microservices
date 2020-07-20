[CmdletBinding()]
param(
)

$currentDirectory = Get-Location
Set-Location $PSScriptRoot

. ./Functions.ps1

$loggingPrefix = "ContentReactor Api Package"

$path =  "./../Service/**"
$destination = "./../.dist/app.zip"

Write-EdenBuildInfo "Removing the API package." $loggingPrefix 
Remove-Item -Path $destination -Recurse -Force -ErrorAction Ignore

Write-EdenBuildInfo "Creating the .dist folder." $loggingPrefix
$result = New-Item -Path "./../" -Name ".dist" -ItemType "directory" -Force
if($VerbosePreference -ne 'SilentlyContinue') { $result }

Write-EdenBuildInfo "Creating the API package." $loggingPrefix
Compress-Archive -Path $path -DestinationPath $destination 

Write-EdenBuildInfo "Finished building the Api package." $loggingPrefix

Set-Location $currentDirectory
