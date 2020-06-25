function Test-AutomatedJob
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
    $automatedTestJob = Start-ThreadJob -Name "rt-Automated" -ScriptBlock {
        $AutomatedUrl = $args[0]
        $Continuous = $args[1]
        $LoggingPrefix = $args[2]
        $VerbosePreference = $args[3]
        $SolutionName = $args[4]
        $ServiceName = $args[5]

        Test-Automated `
            -SolutionName $SolutionName `
            -ServiceName $ServiceName `
            -AutomatedUrl $AutomatedUrl `
            -Continuous:$Continuous `
            -LoggingPrefix $LoggingPrefix
    } -ArgumentList @($AutomatedUrl, $Continuous, $LoggingPrefix, $VerbosePreference, $SolutionName, $ServiceName)
    return $automatedTestJob
}