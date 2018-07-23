function D([string]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $($value)" -ForegroundColor DarkCyan }
function E([string]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $($value)" -ForegroundColor DarkRed }


D("Location: $(Get-Location)")
D("Script Location: $($PSSCriptRoot)")

Set-Location $PSSCriptRoot

Set-Location "..\"

D("Location: $(Get-Location)")

$DirectoryStart = Get-Location

D("Audio Build: DirectoryStart: $DirectoryStart")

D("Audio Build: Building Audio Microservice in $(Get-Location)")

Set-Location "$DirectoryStart\src\ContentReactor.Audio"
D("Audio Build: Running dotnet build in $(Get-Location)")
dotnet build
D("Audio Build: Ran dotnet build in $(Get-Location)")

Set-Location "$DirectoryStart\src\ContentReactor.Audio\ContentReactor.Audio.Services.Tests"
D("Audio Build: Running dotnet test in $(Get-Location)")
dotnet test --logger "trx;logFileName=testResults.trx"
D("Audio Build: Ran dotnet test in $(Get-Location)")

Set-Location "$DirectoryStart\src\ContentReactor.Audio"
D("Audio Build: Running dotnet test in $(Get-Location)")
dotnet publish -c Release
D("Audio Build: Ran dotnet test in $(Get-Location)")

Set-Location "$DirectoryStart\build"
D("Audio Build: Running npm install.")
npm install
D("Audio Build: Ran npm install.")

D("Audio Build: Zipping the API in $(Get-Location)")
node zip.js "$DirectoryStart\deploy\ContentReactor.Audio.Api.zip" "$DirectoryStart\src\ContentReactor.Audio\ContentReactor.Audio.Api\bin\Release\netstandard2.0\publish"
D("Audio Build: Zipped the API in $(Get-Location)")

D("Audio Build: Zipping the Worker in $(Get-Location)")
node zip.js "$DirectoryStart\deploy\ContentReactor.Audio.WorkerApi.zip" "$DirectoryStart\src\ContentReactor.Audio\ContentReactor.Audio.WorkerApi\bin\Release\netstandard2.0\publish"
D("Audio Build: Zipped the Worker in $(Get-Location)")

D("Audio Build: Copy over the latest version of the deploy-microservice.sh script.")
node copy-deploy-microservice.js
D("Audio Build: Copied over the latest version of the deploy-microservice.sh script.")

Set-Location "$DirectoryStart\build"
D("Audio Build: Built Audio Microservice in $(Get-Location)")
