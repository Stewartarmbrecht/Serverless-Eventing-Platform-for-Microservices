function Invoke-CommandTestUnitContinuous 
{
    [CmdletBinding()]
    param(
        [EdenEnvConfig]$EdenEnvConfig
    ) 
    dotnet watch `
        --project ./Service.Tests/$($EdenEnvConfig.SolutionName).$($EdenEnvConfig.ServiceName).Service.Tests.csproj `
        test `
        --logger "trx;logFileName=testResults.trx" `
        --filter TestCategory!=Automated `
        /p:CollectCoverage=true `
        /p:CoverletOutput=TestResults/lcov.info `
        /p:CoverletOutputFormat=lcov `
        /p:Include=[$($EdenEnvConfig.SolutionName).$($EdenEnvConfig.ServiceName).Service*]* `
        /p:Threshold=80 `
        /p:ThresholdType=line `
        /p:ThresholdStat=total | Write-Verbose
    if ($LASTEXITCODE -ne 0) { throw "Running the unit tests exited with an error."}
}