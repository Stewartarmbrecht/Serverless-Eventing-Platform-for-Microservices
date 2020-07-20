[CmdletBinding()]
param(  
    [Alias("c")]
    [switch] $Continuous
)

$solutionName = "ContentReactor"
$serviceName = "Health"

try
{
    $currentDirectory = Get-Location
    Set-Location $PSScriptRoot
    
    . ./Functions.ps1
    
    $loggingPrefix = "$solutionName $serviceName Test Unit"

    $verbose = $VerbosePreference
    
    if ($Continuous) {
        $VerbosePreference = "Continue"
        $command = @"
            dotnet watch --project ./../Service.Tests/$solutionName.$serviceName.Service.Tests.csproj test ``
                --logger "trx;logFileName=testResults.trx" ``
                --filter TestCategory!=Automated ``
                /p:CollectCoverage=true ``
                /p:CoverletOutput=TestResults/lcov.info ``
                /p:CoverletOutputFormat=lcov ``
                /p:Include="[$solutionName.$serviceName.Service*]*" ``
                /p:Threshold=80 ``
                /p:ThresholdType=line ``
                /p:ThresholdStat=total
"@
        $message = "Running the unit tests continuously."
    }
    else 
    {
        $command = @"
            dotnet test ./../Service.Tests/$solutionName.$serviceName.Service.Tests.csproj ``
                --logger "trx;logFileName=testResults.trx" ``
                --filter TestCategory!=Automated ``
                /p:CollectCoverage=true ``
                /p:CoverletOutput=TestResults/lcov.info ``
                /p:CoverletOutputFormat=lcov ``
                /p:Include=`"[$solutionName.$serviceName.Service*]*`" ``
                /p:Threshold=80 ``
                /p:ThresholdType=line ``
                /p:ThresholdStat=total 
"@
        $message = "Running the unit tests."
    }
    
    Invoke-BuildCommand $command $message $loggingPrefix 
    $VerbosePreference = $verbose
    Write-EdenBuildInfo "Finished running unit tests." $loggingPrefix

    Set-Location $currentDirectory
}
catch
{
    $VerbosePreference = $verbose
    Set-Location $currentDirectory
    Write-EdenBuildError "Running unit tests failed." $loggingPrefix
    throw $_
}