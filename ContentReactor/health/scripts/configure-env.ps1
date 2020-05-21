param([String] $systemName, [String] $region, [String] $bigHugeThesaurusApiKey, [String]$userName, [String] $password, [String] $tenantId, [String] $uniqueDeveloperId)

$Env:systemName = $systemName
$Env:region = $region
$Env:bigHugeThesaurusApiKey = $bigHugeThesaurusApiKey
$Env:userName = $userName
$Env:password = $password
$Env:tenantId = $tenantId
$Env:uniqueDeveloperId = $uniqueDeveloperId

if(!$Env:systemName) {
    $Env:systemName = Read-Host -Prompt 'Please provide a prefix to add to the beginning of every resource.  Some resources require globally unique names.  This prefix should guarantee that.'
}
if(!$Env:region) {
    $Env:region = Read-Host -Prompt 'Please provide a region to deploy to.  Hint: WestUS2'
}
if(!$Env:bigHugeThesaurusApiKey) {
    $Env:bigHugeThesaurusApiKey = Read-Host -Prompt 'Please provide an API key for the Big Huge Thesaurus API. You can get a key here: https://words.bighugelabs.com/api.php'
}
if(!$Env:userName) {
    $Env:userName = Read-Host -Prompt 'Please provide the Application (client) ID for a service principle to use for the deployment.'
}
if(!$Env:password) {
    $Env:password = Read-Host -Prompt 'Please provide the service principal secret (password) to use for the deployment.'
}
if(!$Env:tenantId) {
    $Env:tenantId = Read-Host -Prompt 'Please provide the Directory (tenant) ID for the service principal.'
}
if(!$Env:uniqueDeveloperId) {
    $Env:uniqueDeveloperId = Read-Host -Prompt 'Please provide a unique id to identify subscriptions deployed to the cloud for the local developer.'
}
