function Start-EdenCommand
{
    [CmdletBinding()]
    param(
        [String] $EdenCommand,
        $EdenEnvConfig,
        [String] $LoggingPrefix
    ) 
    Write-BuildInfo "Starting the Eden command job: $EdenCommand." $LoggingPrefix
    $job = Start-ThreadJob -Name "cj-$EdenCommand" -ScriptBlock {
        $VerbosePreference = $args[3]
        Write-BuildInfo "Invoking the Eden command: $($args[0])" $args[2]
        Invoke-EdenCommand -EdenCommand $args[0] -EdenEnvConfig $args[1] -LoggingPrefix $args[2]
    } -ArgumentList @($EdenCommand, $EdenEnvConfig, $LoggingPrefix, $VerbosePreference)
    return $job
}