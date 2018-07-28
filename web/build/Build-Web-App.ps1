. ./Logging.ps1

Set-Location "$PSSCriptRoot/../src/ContentReactor.Web/ContentReactor.Web.App"
D("Location: $(Get-Location)")

D("Running npm install in $(Get-Location)")
npm install
D("Ran npm install in $(Get-Location)")

D("Running npm dist in $(Get-Location)")
npm run dist
D("Ran npm dist in $(Get-Location)")

