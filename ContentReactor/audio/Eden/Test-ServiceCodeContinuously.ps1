[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

    Write-EdenBuildInfo "Testing the ContentReactor.Audio.sln Solution continuously using the 'Service.Tests/ContentReactor.Audio.Service.Tests'." $LoggingPrefix
    dotnet watch --project ./Service.Tests/ContentReactor.Audio.Service.Tests.csproj test `
        --filter TestCategory!=Automated `
        /p:CollectCoverage=true `
        /p:CoverletOutput=TestResults/ `
        /p:CoverletOutputFormat=lcov `
        /p:Include="[ContentReactor.Audio.Service*]*" `
        /p:Threshold=80 `
        /p:ThresholdType=line `
        /p:ThresholdStat=total
