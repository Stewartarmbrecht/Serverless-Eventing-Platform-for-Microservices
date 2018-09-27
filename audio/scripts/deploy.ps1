param([String]$namePrefix,[String]$region,[String]$bigHugeThesaurusApiKey,[String]$userName,[String]$password)
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
Set-Location $PSSCriptRoot

. ./../../scripts/functions.ps1

./../build/build.ps1

./../deploy/deploy.ps1 -namePrefix $namePrefix -region $region -bigHugeThesaurusApiKey $bigHugeThesaurusApiKey -userName $userName -password $password