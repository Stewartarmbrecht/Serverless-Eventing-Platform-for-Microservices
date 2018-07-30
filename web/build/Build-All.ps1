$microserviceName = "Web"
$loggingPrefix = "$microserviceName Build"

Set-Location "$PSSCriptRoot"

. ./../../scripts/functions.ps1

$directoryStart = Get-Location

D "Building $microserviceName microservice" $loggingPrefix

D "Building the Web Application." $loggingPrefix
./Build-Web-App.ps1

Set-Location $PSSCriptRoot

D "Building the Web Server." $loggingPrefix
./Build-Web-Server.ps1

Set-Location $PSSCriptRoot

D "Built $microserviceName Microservice" $loggingPrefix
