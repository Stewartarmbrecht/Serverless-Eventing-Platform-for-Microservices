function Invoke-EdenCommand 
{
    [CmdletBinding()]
    param(
        [String] $EdenCommand,
        $EdenEnvConfig,
        [String] $LoggingPrefix
    )

    $edenCommandFile = "./Eden/$EdenCommand.ps1"

    if (!(Test-Path $edenCommandFile)) {
        throw "Could not find the file '$edenCommandFile' to execute the Eden command.  Please add the file to the Eden folder."
    } else {
        # Write-Verbose "Calling $edenCommandFile"
        & $edenCommandFile -EdenEnvConfig $EdenEnvConfig -LoggingPrefix $LoggingPrefix
    }
}