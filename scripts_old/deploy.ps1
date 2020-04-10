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

if(!$namePrefix) {
    $namePrefix = Read-Host -Prompt 'Please provide a prefix to add to the beginning of every resource.  Some resources require globally unique names.  This prefix should guarantee that.'
}
if(!$region) {
    $region = Read-Host -Prompt 'Please provide a region to deploy to.  Hint: WestUS2'
}
if(!$bigHugeThesaurusApiKey) {
    $bigHugeThesaurusApiKey = Read-Host -Prompt 'Please provide an API key for the Big Huge Thesaurus API. You can get a key here: https://words.bighugelabs.com/api.php'
}
if(!$userName) {
    $userName = Read-Host -Prompt 'Please provide the Application (client) ID for a service principle to use for the deployment.'
}
if(!$password) {
    $password = Read-Host -Prompt 'Please provide the service principal secret (password) to use for the deployment.'
}
if(!$tenantId) {
    $tenantId = Read-Host -Prompt 'Please provide the Directory (tenant) ID for the service principal.'
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

D "Deploying Health" $loggingPrefix
Start-Job -Name "DeployHealth" -ScriptBlock {
    Set-Location $args[0]
    ../health/deploy/deploy.ps1 -namePrefix $args[1] -region $args[2] -userName $args[3] -password $args[4] -tenantId $args[5]
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
