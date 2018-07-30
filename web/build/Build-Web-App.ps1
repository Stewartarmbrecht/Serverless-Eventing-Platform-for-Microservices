$microserviceName = "Web App"
$loggingPrefix = "$microserviceName Build"

Set-Location "$PSSCriptRoot/../"

. ./../scripts/functions.ps1

$directoryStart = Get-Location

Set-Location "$directoryStart/src/ContentReactor.Web/ContentReactor.Web.App"

ExecuteCommand "npm install" $loggingPrefix "Installing web app dependencies."

ExecuteCommand "npm run dist" $loggingPrefix "Building web app distribution package."