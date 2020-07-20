[CmdletBinding()]
param(
    [Parameter()]
    [Switch]$Continuous,
    [Parameter()]
    [switch]$RunAutomatedTests,
    [Parameter()]
    [switch]$RunAutomatedTestsContinuously
)

$solutionName = "ContentReactor"
$serviceName = "Health"

try {

    $currentDirectory = Get-Location
    Set-Location $PSScriptRoot

    . ./Functions.ps1

    ./Configure-Environment -Check

    $instanceName = $Env:InstanceName
    $port = $Env:HealthLocalHostingPort

    $loggingPrefix = "$solutionName $serviceName Run $instanceName"

    Write-EdenBuildInfo "Starting jobs." $loggingPrefix

    Start-Function -FunctionLocation "./../Service" -Port $port -LoggingPrefix $loggingPrefix

    $serviceUrl = "http://localhost:$port"
    $healthCheck = $FALSE
    $testing = $FALSE

    While(Get-Job -State "Running")
    {
        if ($FALSE -eq $healthCheck -and ![string]::IsNullOrEmpty($serviceUrl)) {
            $healthCheck = Get-HealthStatus -PublicUrl $serviceUrl -LoggingPrefix $loggingPrefix
        }

        if(
            ($RunAutomatedTestsContinuously -or $RunAutomatedTests) `
            -and $FALSE -eq $testing `
            -and "" -ne $serviceUrl `
            -and $TRUE -eq $healthCheck) {
            if ($RunAutomatedTestsContinuously) {
                $automatedTestJob = Test-Automated `
                    -SolutionName $solutionName `
                    -ServiceName $serviceName `
                    -AutomatedUrl "http://localhost:$port/api" `
                    -LoggingPrefix $loggingPrefix `
                    -Continuous
            } else {
                $automatedTestJob = Test-Automated `
                    -SolutionName $solutionName `
                    -ServiceName $serviceName `
                    -AutomatedUrl "http://localhost:$port/api" `
                    -LoggingPrefix $loggingPrefix
            }
            $testing = $TRUE
        }

        if ($automatedTestJob -and $automatedTestJob.State -ne "Running")
        {
            if ($automatedTestJob.State -eq "Failed")
            {
                throw "Automated tests failed."
            }
            Write-EdenBuildInfo "Stopping and removing jobs." $loggingPrefix
            Stop-Job rt-*
            Remove-Job rt-*
            Write-EdenBuildInfo "Stopped." $loggingPrefix
        }
        Get-Job | Receive-Job | Write-Verbose
    }

    Get-Job | Receive-Job | Write-Verbose

    if (Get-Job -State "Failed") 
    {
        throw "One of the jobs failed."
    }

    Set-Location $currentDirectory
} 
catch 
{
    Write-EdenBuildInfo "Stopping and removing jobs." $loggingPrefix
    Stop-Job rt-*
    Remove-Job rt-*
    Write-EdenBuildInfo "Stopped." $loggingPrefix
    throw $_
}