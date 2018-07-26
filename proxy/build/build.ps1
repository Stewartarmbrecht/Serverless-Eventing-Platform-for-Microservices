$microserviceName = "Proxy"

function D([string]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $microserviceName Build: $($value)" -ForegroundColor DarkCyan }
function E([string]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $microserviceName Build: $($value)" -ForegroundColor DarkRed }


D("Location: $(Get-Location)")
D("Script Location: $($PSSCriptRoot)")

Set-Location $PSSCriptRoot

Set-Location "..\"

D("Location: $(Get-Location)")

$directoryStart = Get-Location

D("DirectoryStart: $directoryStart")

Set-Location "$directoryStart\build"
D("Running npm install.")
npm install
D("Ran npm install.")

D("Zipping the API in $(Get-Location)")
node zip.js "$directoryStart\deploy\ContentReactor.$microserviceName.Api.zip" "$directoryStart\proxies"
D("Zipped the API in $(Get-Location)")

Set-Location "$directoryStart\build"
D("Built $microserviceName Microservice in $(Get-Location)")
