param([String]$namePrefix,[String]$region,[String]$bigHugeThesaurusApiKey)

function D([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourcePrefix Build and Deploy: $value"  -ForegroundColor DarkCyan }
function E([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourcePrefix Build and Deploy: $value"  -ForegroundColor DarkRed }

D("Please make sure to login and connect to the correct subscription:")
D("`taz login")
D("`taz account set --subscription {your-subscription-id}") 

D("Location: $(Get-Location)")
D("Script Location: $($PSSCriptRoot)")


D("Setting location to the scripts folder")
Set-Location $PSSCriptRoot
$location = Get-Location

D("Building the Solution")
./build.ps1
D("Solution Built")

D("Deploying the Solution")
./deploy.ps1 -namePrefix $namePrefix -region $region -bigHugeThesaurusApiKey $bigHugeThesaurusApiKey
D("Solution Deployed")

D("Build and Deployment complete!")
