function Invoke-ContinuousTestUnitCommand 
{
    [CmdletBinding()]
    param(
        [String]$SolutionName,
        [String]$ServiceName
    ) 
    dotnet watch --project ./Service.Tests/$SolutionName.$ServiceName.Service.Tests.csproj test `
        --logger "trx;logFileName=testResults.trx" `
        --filter TestCategory!=Automated `
        /p:CollectCoverage=true `
        /p:CoverletOutput=TestResults/lcov.info `
        /p:CoverletOutputFormat=lcov `
        /p:Include=[$SolutionName.$ServiceName.Service*]* `
        /p:Threshold=80 `
        /p:ThresholdType=line `
        /p:ThresholdStat=total | Write-Verbose
    if ($LASTEXITCODE -ne 0) { throw "Running the unit tests exited with an error."}
}