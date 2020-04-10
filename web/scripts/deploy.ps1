param([String] $systemName, [String] $region, [String] $userName, [String] $password, [String] $tenantId, [bool] $verboseLogging)
if (!$systemName) {
    $systemName = $Env:systemName
}
if (!$region) {
    $region = $Env:region
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
if (!$verboseLogging) {
    $verboseLogging = $Env:verboseLogging
}

if(!$systemName) {
    $systemName = Read-Host -Prompt 'Please provide a prefix to add to the beginning of every resource.  Some resources require globally unique names.  This prefix should guarantee that.'
}
if(!$region) {
    $region = Read-Host -Prompt 'Please provide a region to deploy to.  Hint: WestUS2'
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

$location = Get-Location

Set-Location $PSSCriptRoot

. ./../../scripts/functions.ps1

./../build/build.ps1 -verboseLogging $verboseLogging

./../deploy/deploy.ps1 -systemName $systemName -region $region -userName $userName -password $password -tenantId $tenantId -verboseLogging $verboseLogging

Set-Location $location