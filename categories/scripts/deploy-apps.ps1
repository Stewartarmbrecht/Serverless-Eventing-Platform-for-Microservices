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

Set-Location $PSSCriptRoot

. ./../../scripts/functions.ps1

./../build/build.ps1

./../deploy/deploy-apps.ps1 -namePrefix $namePrefix -region $region -bigHugeThesaurusApiKey $bigHugeThesaurusApiKey -userName $userName -password $password -tenantId $tenantId