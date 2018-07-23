
Write-Host "Location: $(Get-Location)" -ForegroundColor DarkCyan
Write-Host "Script Location: $($PSSCriptRoot)"

Set-Location $PSSCriptRoot

Set-Location "..\"

Write-Host "Location: $(Get-Location)"

$DirectoryStart = Get-Location

Write-Host "Audio Build: DirectoryStart: $DirectoryStart" -ForegroundColor DarkCyan

Write-Host "Audio Build: Building Audio Microservice in $(Get-Location)" -ForegroundColor DarkCyan

Set-Location "$DirectoryStart\src\ContentReactor.Audio"
Write-Host "Audio Build: Running dotnet build in $(Get-Location)" -ForegroundColor DarkCyan
dotnet build
Write-Host "Audio Build: Ran dotnet build in $(Get-Location)" -ForegroundColor DarkCyan

Set-Location "$DirectoryStart\src\ContentReactor.Audio\ContentReactor.Audio.Services.Tests"
Write-Host "Audio Build: Running dotnet test in $(Get-Location)" -ForegroundColor DarkCyan
dotnet test --logger "trx;logFileName=testResults.trx"
Write-Host "Audio Build: Ran dotnet test in $(Get-Location)" -ForegroundColor DarkCyan

Set-Location "$DirectoryStart\src\ContentReactor.Audio"
Write-Host "Audio Build: Running dotnet test in $(Get-Location)" -ForegroundColor DarkCyan
dotnet publish -c Release
Write-Host "Audio Build: Ran dotnet test in $(Get-Location)" -ForegroundColor DarkCyan

Set-Location "$DirectoryStart\build"
Write-Host "Audio Build: Running npm install." -ForegroundColor DarkCyan
npm install
Write-Host "Audio Build: Ran npm install." -ForegroundColor DarkCyan

Write-Host "Audio Build: Zipping the API in $(Get-Location)" -ForegroundColor DarkCyan
node zip.js "$DirectoryStart\deploy\ContentReactor.Audio.Api.zip" "$DirectoryStart\src\ContentReactor.Audio\ContentReactor.Audio.Api\bin\Release\netstandard2.0\publish"
Write-Host "Audio Build: Zipped the API in $(Get-Location)" -ForegroundColor DarkCyan

Write-Host "Audio Build: Zipping the Worker in $(Get-Location)" -ForegroundColor DarkCyan
node zip.js "$DirectoryStart\deploy\ContentReactor.Audio.WorkerApi.zip" "$DirectoryStart\src\ContentReactor.Audio\ContentReactor.Audio.WorkerApi\bin\Release\netstandard2.0\publish"
Write-Host "Audio Build: Zipped the Worker in $(Get-Location)" -ForegroundColor DarkCyan

Write-Host "Audio Build: Copy over the latest version of the deploy-microservice.sh script." -ForegroundColor DarkCyan
node copy-deploy-microservice.js
Write-Host "Audio Build: Copied over the latest version of the deploy-microservice.sh script." -ForegroundColor DarkCyan

Set-Location "$DirectoryStart\build"
Write-Host "Audio Build: Built Audio Microservice in $(Get-Location)" -ForegroundColor DarkCyan
