$loggingPrefix = "System Build"

Set-Location $PSSCriptRoot

. ./functions.ps1

D "Audio Microservice Build" $loggingPrefix
../audio/build/build.ps1

Set-Location $PSSCriptRoot

D "Categories Microservice Build" $loggingPrefix
../categories/build/build.ps1

Set-Location $PSSCriptRoot

D "Images Microservice Build" $loggingPrefix
../images/build/build.ps1

Set-Location $PSSCriptRoot

D "Text Microservice Build" $loggingPrefix
../text/build/build.ps1

Set-Location $PSSCriptRoot

D "Health Build" $loggingPrefix
../health/build/build.ps1

Set-Location $PSSCriptRoot

D "Proxy Build" $loggingPrefix
../proxy/build/build.ps1

Set-Location $PSSCriptRoot

D "Web Build" $loggingPrefix
../web/build/build.ps1

Set-Location $PSSCriptRoot

D "Build complete!" $loggingPrefix
