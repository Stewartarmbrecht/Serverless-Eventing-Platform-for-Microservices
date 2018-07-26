$microserviceName = "Text"

function D([string]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $microserviceName Build: $($value)" -ForegroundColor DarkCyan }
function E([string]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $microserviceName Build: $($value)" -ForegroundColor DarkRed }


D("Location: $(Get-Location)")
D("Script Location: $($PSSCriptRoot)")

Set-Location $PSSCriptRoot

Set-Location "..\"

D("Location: $(Get-Location)")

$DirectoryStart = Get-Location

D("DirectoryStart: $DirectoryStart")

D("Building $microserviceName Microservice in $(Get-Location)")

Set-Location "$DirectoryStart\src\ContentReactor.$microserviceName"
D("Running dotnet build in $(Get-Location)")
dotnet build
D("Ran dotnet build in $(Get-Location)")

Set-Location "$DirectoryStart\src\ContentReactor.$microserviceName\ContentReactor.$microserviceName.Services.Tests"
D("Running dotnet test in $(Get-Location)")
dotnet test --logger "trx;logFileName=testResults.trx"
D("Ran dotnet test in $(Get-Location)")

Set-Location "$DirectoryStart\src\ContentReactor.$microserviceName"
D("Running dotnet test in $(Get-Location)")
dotnet publish -c Release
D("Ran dotnet test in $(Get-Location)")

Set-Location "$DirectoryStart\build"
D("Running npm install.")
npm install
D("Ran npm install.")

D("Zipping the API in $(Get-Location)")
node zip.js "$DirectoryStart\deploy\ContentReactor.$microserviceName.Api.zip" "$DirectoryStart\src\ContentReactor.$microserviceName\ContentReactor.$microserviceName.Api\bin\Release\netstandard2.0\publish"
D("Zipped the API in $(Get-Location)")

Set-Location "$DirectoryStart\build"
D("Built $microserviceName Microservice in $(Get-Location)")
