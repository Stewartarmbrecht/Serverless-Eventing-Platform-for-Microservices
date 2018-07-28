. ./Logging.ps1

Set-Location "$PSSCriptRoot/../"
$directoryStart = Get-Location
D("Location: $(Get-Location)")

Set-Location "$directoryStart\src\ContentReactor.Web\ContentReactor.Web.Server"
D("Running dotnet build in $(Get-Location)")
dotnet build
D("Ran dotnet build in $(Get-Location)")

Set-Location "$directoryStart\src\ContentReactor.Web\ContentReactor.Web.Tests"
D("Running dotnet test in $(Get-Location)")
dotnet test --logger "trx;logFileName=testResults.trx"
D("Ran dotnet test in $(Get-Location)")

Set-Location "$directoryStart\src\ContentReactor.Web\ContentReactor.Web.Server"
D("Running dotnet test in $(Get-Location)")
dotnet publish -c Release
D("Ran dotnet test in $(Get-Location)")

$path = "$directoryStart\src\ContentReactor.Web\ContentReactor.Web.Server\bin\Release\netcoreapp2.1\publish\"
$destination = "$directoryStart\deploy\.dist\"
D("Deleting the web app folder in $destination")
Remove-Item -Path $destination -Recurse -Force -ErrorAction Ignore
D("Deleted the web app folder in $destination")

D("Copying the web app in $path to $destination")
Copy-Item -Path $path -Destination $destination -Recurse -Force
D("Copyied the web app in $path to $destination")
