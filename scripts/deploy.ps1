param([String] $namePrefix, [String] $region, [String] $bigHugeThesaurusApiKey, [String]$userName, [String] $password, [String] $tenantId)
if (!$namePrefix) {
    $namePrefix = $Env:namePrefix
}
if (!$region) {
    $region = $Env:region
}
if (!$bigHugeThesaurusApiKey) {
    $bigHugeThesaurusApiKey = $Env:bigHugeThesaurusApiKey
}
if (!$userName) {
    $userName = $Env:userName
}
if (!$password) {
    $password = $Env:password
}
if (!$tenantId) {
    $tenantId = $Env:tenantId
}
$loggingPrefix = "System Build"

Set-Location $PSSCriptRoot

$location = Get-Location

. ./functions.ps1

D "Deploying Events" $loggingPrefix
Start-Job -Name "DeployEvents" -ScriptBlock {
    Set-Location $args[0]
    ../events/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2] -userName $args[3] -password $args[4] -tenantId $args[5]
} -ArgumentList @($location,$namePrefix,$region,$userName,$password,$tenantId)

While(Get-Job -State "Running")
{
    D "Running the following jobs:" $loggingPrefix
    Get-Job -State "Running"
    Get-Job | Receive-Job
    Start-Sleep -Seconds 30
}

Get-Job | Wait-Job
Get-Job | Receive-Job

D "Deploying Categories" $loggingPrefix
Start-Job -Name "DeployCategories" -ScriptBlock {
    Set-Location $args[0]
    ../categories/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2] -bigHugeThesaurusApiKey $args[3] -userName $args[4] -password $args[5] -tenantId $args[6]
} -ArgumentList @($location,$namePrefix,$region,$bigHugeThesaurusApiKey,$userName,$password,$tenantId)

D "Deploying Images" $loggingPrefix
Start-Job -Name "DeployImages" -ScriptBlock {
    Set-Location $args[0]
    ../images/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2] -userName $args[3] -password $args[4] -tenantId $args[5]
} -ArgumentList @($location,$namePrefix,$region,$userName,$password,$tenantId)

D "Deploying Audio" $loggingPrefix
Start-Job -Name "DeployAudio" -ScriptBlock {
    Set-Location $args[0]
    ../audio/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2] -userName $args[3] -password $args[4] -tenantId $args[5]
} -ArgumentList @($location,$namePrefix,$region,$userName,$password,$tenantId)

D "Deploying Text" $loggingPrefix
Start-Job -Name "DeployText" -ScriptBlock {
    Set-Location $args[0]
    ../text/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2] -userName $args[3] -password $args[4] -tenantId $args[5]
} -ArgumentList @($location,$namePrefix,$region,$userName,$password,$tenantId)

While(Get-Job -State "Running")
{
    D "Running the following jobs:" $loggingPrefix
    Get-Job -State "Running"
    Get-Job | Receive-Job
    Start-Sleep -Seconds 30
}

Get-Job | Wait-Job
Get-Job | Receive-Job

D "Deploying API Proxy" $loggingPrefix
Start-Job -Name "DeployAPIProxy" -ScriptBlock {
    Set-Location $args[0]
    ../proxy/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2] -userName $args[3] -password $args[4] -tenantId $args[5]
} -ArgumentList @($location,$namePrefix,$region,$userName,$password,$tenantId)

D "Deploying Web" $loggingPrefix
Start-Job -Name "DeployWeb" -ScriptBlock {
    Set-Location $args[0]
    ../web/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2] -userName $args[3] -password $args[4] -tenantId $args[5]
} -ArgumentList @($location,$namePrefix,$region,$userName,$password,$tenantId)

While(Get-Job -State "Running")
{
    D "Running the following jobs:" $loggingPrefix
    Get-Job -State "Running"
    Get-Job | Receive-Job
    Start-Sleep -Seconds 30
}

Get-Job | Wait-Job
Get-Job | Receive-Job

D "Deployment complete!" $loggingPrefix
