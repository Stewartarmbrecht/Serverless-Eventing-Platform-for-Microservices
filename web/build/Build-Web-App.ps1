$microserviceName = "Web App"
$loggingPrefix = "$microserviceName Build"

Set-Location "$PSSCriptRoot/../"

. ./../scripts/functions.ps1

$directoryStart = Get-Location

Set-Location "$directoryStart/src/ContentReactor.Web/ContentReactor.Web.App"

$old_ErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

$result = ExecuteCommand "npm install" $loggingPrefix "Installing web app dependencies."

$ErrorActionPreference = $old_ErrorActionPreference 

$result = ExecuteCommand "npm run build" $loggingPrefix "Building web app distribution package."

$path =  "$directoryStart/src/ContentReactor.Web/ContentReactor.Web.App/dist/"
$destination = "$directoryStart/src/ContentReactor.Web/ContentReactor.Web.Server/wwwroot/"

$result = ExecuteCommand "Remove-Item -Path $destination -Recurse -Force -ErrorAction Ignore" $loggingPrefix "Removing the web app from the wwwroot folder."

$result = ExecuteCommand "Copy-Item -Path $path -Destination $destination -Recurse -Force" $loggingPrefix "Copying the the web app files to the wwwroot folder."

