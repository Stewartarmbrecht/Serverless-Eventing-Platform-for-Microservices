function D([string]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $microserviceName Build: $($value)" -ForegroundColor DarkCyan }
function E([string]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $microserviceName Build: $($value)" -ForegroundColor DarkRed }

D("Location: $(Get-Location)")
D("Script Location: $($PSSCriptRoot)")

Set-Location $PSSCriptRoot

D("Categories Microservice Build")
../categories/build/build.ps1

Set-Location $PSSCriptRoot

D("Images Microservice Build")
../images/build/build.ps1

Set-Location $PSSCriptRoot

D("Audio Microservice Build")
../audio/build/build.ps1

Set-Location $PSSCriptRoot

D("Text Microservice Build")
../text/build/build.ps1

Set-Location $PSSCriptRoot

D("Proxy Build")
../proxy/build/build.ps1

Set-Location $PSSCriptRoot

D("Web Build")
../web/build/build.ps1

Set-Location $PSSCriptRoot

D("Build complete!")
