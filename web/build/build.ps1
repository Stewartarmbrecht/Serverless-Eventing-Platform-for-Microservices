$microserviceName = "Web"

function D([string]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $microserviceName Build: $($value)" -ForegroundColor DarkCyan }
function E([string]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $microserviceName Build: $($value)" -ForegroundColor DarkRed }


D("Location: $(Get-Location)")
D("Script Location: $($PSSCriptRoot)")

Set-Location $PSSCriptRoot

Set-Location "..\"

D("Location: $(Get-Location)")

$directoryStart = Get-Location

D("DirectoryStart: $directoryStart")

D("Building $microserviceName Microservice in $(Get-Location)")

Set-Location "$directoryStart\src\signalr-web\SignalRMiddleware\EventApp"
D("Running npm install in $(Get-Location)")
npm install
D("Ran npm install in $(Get-Location)")

D("Running npm dist in $(Get-Location)")
npm run dist
D("Ran npm dist in $(Get-Location)")

Set-Location "$directoryStart\src\signalr-web\SignalRMiddleware"
D("Running dotnet build in $(Get-Location)")
dotnet build
D("Ran dotnet build in $(Get-Location)")

Set-Location "$directoryStart\src\signalr-web\SignalRMiddleware\SignalRMiddlewareTests"
D("Running dotnet test in $(Get-Location)")
dotnet test --logger "trx;logFileName=testResults.trx"
D("Ran dotnet test in $(Get-Location)")

Set-Location "$directoryStart\src\signalr-web\SignalRMiddleware\SignalRMiddleware"
D("Running dotnet test in $(Get-Location)")
dotnet publish -c Release
D("Ran dotnet test in $(Get-Location)")

Set-Location "$directoryStart\build"
D("Running npm install.")
npm install
D("Ran npm install.")

D("Copying the web app in $(Get-Location)")
node copy-directory.js "$directoryStart\deploy\.dist" "$directoryStart\src\signalr-web\SignalRMiddleware\SignalRMiddleware\bin\Release\netcoreapp2.1\publish"
D("Copied the web app in $(Get-Location)")

Set-Location "$directoryStart\build"
D("Built $microserviceName Microservice in $(Get-Location)")
