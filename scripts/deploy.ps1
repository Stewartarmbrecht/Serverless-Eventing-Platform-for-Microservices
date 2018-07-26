param([String]$namePrefix,[String]$region,[String]$bigHugeThesaurusApiKey)

function D([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourcePrefix Deploy: $value"  -ForegroundColor DarkCyan }
function E([String]$value) { Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $resourcePrefix Deploy: $value"  -ForegroundColor DarkRed }

D("Please make sure to login and connect to the correct subscription:")
D("`taz login")
D("`taz account set --subscription {your-subscription-id}}") 

D("Location: $(Get-Location)")
D("Script Location: $($PSSCriptRoot)")


D("Setting location to the scripts folder")
Set-Location $PSSCriptRoot
$location = Get-Location

D("Deploying Events")
Start-Job -Name "DeployEvents" -ScriptBlock {
    Set-Location $args[0]
    ../events/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2]
} -ArgumentList @($location,$namePrefix,$region)

While(Get-Job -State "Running")
{
    Get-Job -State "Running"
    Get-Job | Receive-Job
    Start-Sleep -Seconds 5
}

Get-Job | Wait-Job
Get-Job | Receive-Job

D("Deploying Categories")
Start-Job -Name "DeployCategories" -ScriptBlock {
    Set-Location $args[0]
    ../categories/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2] -bigHugeThesaurusApiKey $args[3]
} -ArgumentList @($location,$namePrefix,$region,$bigHugeThesaurusApiKey)

D("Deploying Images")
Start-Job -Name "DeployImages" -ScriptBlock {
    Set-Location $args[0]
    ../images/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2]
} -ArgumentList @($location,$namePrefix,$region)

D("Deploying Audio")
Start-Job -Name "DeployAudio" -ScriptBlock {
    Set-Location $args[0]
    ../audio/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2]
} -ArgumentList @($location,$namePrefix,$region)

D("Deploying Text")
Start-Job -Name "DeployText" -ScriptBlock {
    Set-Location $args[0]
    ../text/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2]
} -ArgumentList @($location,$namePrefix,$region)

While(Get-Job -State "Running")
{
    Get-Job -State "Running"
    Get-Job | Receive-Job
    Start-Sleep -Seconds 5
}

Get-Job | Wait-Job
Get-Job | Receive-Job

D("Deploying API Proxy")
Start-Job -Name "DeployAPIProxy" -ScriptBlock {
    Set-Location $args[0]
    ../proxy/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2]
} -ArgumentList @($location,$namePrefix,$region)

D("Deploying Web")
Start-Job -Name "DeployWeb" -ScriptBlock {
    Set-Location $args[0]
    ../web/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2]
} -ArgumentList @($location,$namePrefix,$region)

While(Get-Job -State "Running")
{
    Get-Job -State "Running"
    Get-Job | Receive-Job
    Start-Sleep -Seconds 5
}

Get-Job | Wait-Job
Get-Job | Receive-Job

D("Deployment complete!")
