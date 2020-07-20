function Start-EdenCommand
{
    [CmdletBinding()]
    param(
        [String] $EdenCommand,
        $EdenEnvConfig,
        [String] $LoggingPrefix
    ) 
    Write-EdenBuildInfo "Starting the Eden command job: $EdenCommand." $LoggingPrefix
    $scriptRoot = $PSScriptRoot
    $job = Start-ThreadJob -Name "cj-$EdenCommand" -ScriptBlock {
        Import-Module (Join-Path $args[4] "../../Eden/Eden.psm1")
        $VerbosePreference = $args[3]
        . (Join-Path $args[4] "./Invoke-EdenCommand.ps1")
        Write-EdenBuildInfo "Invoking the Eden command: $($args[0])" $args[2]
        Invoke-EdenCommand -EdenCommand $args[0] -EdenEnvConfig $args[1] -LoggingPrefix $args[2]
    } -ArgumentList @($EdenCommand, $EdenEnvConfig, $LoggingPrefix, $VerbosePreference, $scriptRoot)
    return $job
}