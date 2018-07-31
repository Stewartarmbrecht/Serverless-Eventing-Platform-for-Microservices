param([String]$namePrefix,[String]$region,[String]$bigHugeThesaurusApiKey)
if (!$namePrefix) {
    $namePrefix = $Env:namePrefix
}
if (!$region) {
    $region = $Env:region
}
if (!$bigHugeThesaurusApiKey) {
    $bigHugeThesaurusApiKey = $Env:bigHugeThesaurusApiKey
}
$loggingPrefix = "System Build"

Set-Location $PSSCriptRoot

$location = Get-Location

. ./functions.ps1

D "Deploying Events" $loggingPrefix
Start-Job -Name "DeployEvents" -ScriptBlock {
    Set-Location $args[0]
    ../events/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2]
} -ArgumentList @($location,$namePrefix,$region)

While(Get-Job -State "Running")
{
    D "Running the following jobs:" $loggingPrefix
    Get-Job -State "Running"
    Get-Job | Receive-Job
    Start-Sleep -Seconds 5
}

Get-Job | Wait-Job
Get-Job | Receive-Job

D "Deploying Categories" $loggingPrefix
Start-Job -Name "DeployCategories" -ScriptBlock {
    Set-Location $args[0]
    ../categories/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2] -bigHugeThesaurusApiKey $args[3]
} -ArgumentList @($location,$namePrefix,$region,$bigHugeThesaurusApiKey)

D "Deploying Images" $loggingPrefix
Start-Job -Name "DeployImages" -ScriptBlock {
    Set-Location $args[0]
    ../images/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2]
} -ArgumentList @($location,$namePrefix,$region)

D "Deploying Audio" $loggingPrefix
Start-Job -Name "DeployAudio" -ScriptBlock {
    Set-Location $args[0]
    ../audio/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2]
} -ArgumentList @($location,$namePrefix,$region)

D "Deploying Text" $loggingPrefix
Start-Job -Name "DeployText" -ScriptBlock {
    Set-Location $args[0]
    ../text/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2]
} -ArgumentList @($location,$namePrefix,$region)

While(Get-Job -State "Running")
{
    D "Running the following jobs:" $loggingPrefix
    Get-Job -State "Running"
    Get-Job | Receive-Job
    Start-Sleep -Seconds 5
}

Get-Job | Wait-Job
Get-Job | Receive-Job

D "Deploying API Proxy" $loggingPrefix
Start-Job -Name "DeployAPIProxy" -ScriptBlock {
    Set-Location $args[0]
    ../proxy/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2]
} -ArgumentList @($location,$namePrefix,$region)

D "Deploying Web" $loggingPrefix
Start-Job -Name "DeployWeb" -ScriptBlock {
    Set-Location $args[0]
    ../web/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2]
} -ArgumentList @($location,$namePrefix,$region)

While(Get-Job -State "Running")
{
    D "Running the following jobs:" $loggingPrefix
    Get-Job -State "Running"
    Get-Job | Receive-Job
    Start-Sleep -Seconds 5
}

Get-Job | Wait-Job
Get-Job | Receive-Job

D "Deployment complete!" $loggingPrefix
