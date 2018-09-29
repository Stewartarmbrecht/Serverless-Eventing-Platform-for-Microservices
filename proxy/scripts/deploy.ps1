param([String] $namePrefix, [String] $region, [String] $userName, [String] $password )
if (!$namePrefix) {
    $namePrefix = $Env:namePrefix
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
Set-Location $PSSCriptRoot

. ./../../scripts/functions.ps1

./../build/build.ps1

./../deploy/deploy.ps1 -namePrefix $namePrefix -region $region -userName $userName -password $password
