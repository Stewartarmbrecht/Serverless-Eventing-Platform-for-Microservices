. .\Logging.ps1

$microserviceName = "Web"

Set-Location $PSSCriptRoot

D("Building $microserviceName Microservice in $(Get-Location)")

D("Building the Web Application.")
./Build-Web-App.ps1
D("Built the Web Application.")

Set-Location $PSSCriptRoot

D("Building the Web Server.")
./Build-Web-Server.ps1
D("Built the Web Server.")

Set-Location $PSSCriptRoot

D("Built $microserviceName Microservice in $(Get-Location)")
