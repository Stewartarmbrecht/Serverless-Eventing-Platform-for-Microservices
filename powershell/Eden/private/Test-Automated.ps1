function Test-Automated
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [String]$SolutionName,
        [Parameter(Mandatory=$TRUE)]
        [String]$ServiceName,
        [Parameter(Mandatory=$TRUE)]
        [String]$AutomatedUrl,
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix,
        [Parameter()]
        [switch]$Continuous
    )
    $automatedTestJob = Start-Job -Name "rt-Automated" -ScriptBlock {
        $AutomatedUrl = $args[0]
        $Continuous = $args[1]
        $LoggingPrefix = $args[2]
        $VerbosePreference = $args[3]
        $SolutionName = $args[4]
        $ServiceName = $args[5]

        . ./Functions.ps1
    
        $Env:AutomatedUrl = $AutomatedUrl
        Write-BuildInfo "Running automated tests against '$AutomatedUrl'." $LoggingPrefix

        if ($Continuous)
        {
            Invoke-BuildCommand "dotnet watch --project ./../Service.Tests/$SolutionName.$ServiceName.Service.Tests.csproj test --filter TestCategory=Automated" "Running automated tests continuously." $LoggingPrefix
        }
        else
        {
            Invoke-BuildCommand "dotnet test ./../Service.Tests/$SolutionName.$ServiceName.Service.Tests.csproj --filter TestCategory=Automated" "Running automated tests once." $LoggingPrefix
            Write-BuildInfo "Finished running automated tests." $LoggingPrefix
        }
    } -ArgumentList @($AutomatedUrl, $Continuous, $LoggingPrefix, $VerbosePreference, $SolutionName, $ServiceName)
    return $automatedTestJob
}