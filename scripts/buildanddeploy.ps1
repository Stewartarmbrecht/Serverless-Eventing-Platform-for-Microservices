param([String]$namePrefix,[String]$region,[String]$bigHugeThesaurusApiKey)

. ./functions.ps1


if (!$namePrefix) {
    $namePrefix = $Env:namePrefix
}
if(!$namePrefix) {
    $namePrefix = Read-Host -Prompt 'Please provide a prefix to add to the beginning of every resource.  Some resources require globally unique names.  This prefix should guarantee that.'
}
if (!$region) {
    $region = $Env:region
}
if(!$region) {
    $region = Read-Host -Prompt 'Please provide a region to deploy to.  Hint: WestUS2'
}
if (!$bigHugeThesaurusApiKey) {
    $bigHugeThesaurusApiKey = $Env:bigHugeThesaurusApiKey
}
if(!$bigHugeThesaurusApiKey) {
    $bigHugeThesaurusApiKey = Read-Host -Prompt 'Please provide an API key for the Big Huge Thesaurus API. You can get a key here: https://words.bighugelabs.com/api.php'
}
$loggingPrefix = "System Build"

D "Using Name Prefix: $namePrefix" $loggingPrefix
D "Using Region: $region" $loggingPrefix
D "Using Thesaurus Key: $bigHugeThesaurusApiKey" $loggingPrefix

Set-Location $PSSCriptRoot

az login

./build.ps1

./deploy.ps1 -namePrefix $namePrefix -region $region -bigHugeThesaurusApiKey $bigHugeThesaurusApiKey