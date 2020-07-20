[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

    Write-EdenBuildInfo "Testing the ContentReactor.Audio.sln Solution using the 'Service.Tests/ContentReactor.Audio.Service.Tests'." $LoggingPrefix
    dotnet test ./Service.Tests/ContentReactor.Audio.Service.Tests.csproj `
        --logger "trx;logFileName=testResults.trx" `
        --filter TestCategory!=Automated `
        /p:CollectCoverage=true `
        /p:CoverletOutput=TestResults/ `
        /p:CoverletOutputFormat=lcov `
        /p:Include=`"[ContentReactor.Audio.Service*]*`" `
        /p:Threshold=80 `
        /p:ThresholdType=line `
        /p:ThresholdStat=total 
    Write-EdenBuildInfo "Finished testing the ContentReactor.Audio.sln Solution using the 'Service.Tests/ContentReactor.Audio.Service.Tests'." $LoggingPrefix
