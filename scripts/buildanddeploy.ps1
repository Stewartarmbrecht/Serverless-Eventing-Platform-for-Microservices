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

. ./functions.ps1

./build.ps1

./deploy.ps1 -namePrefix $namePrefix -region $region -bigHugeThesaurusApiKey $bigHugeThesaurusApiKey