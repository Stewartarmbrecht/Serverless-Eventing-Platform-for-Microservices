function Start-LocalTunnelJob
{
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '', Scope='Function')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [Int32]$Port,
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix
    )

    $importFunctionPath = (Join-Path $PSScriptRoot "Import-PrivateFunctions.ps1")

    Start-ThreadJob -Name "rt-Tunnel" -ScriptBlock {

        $VerbosePreference = $args[2]

        . $args[3]

        Start-LocalTunnel -Port $args[0] -LoggingPrefix $args[1]
    
    } -ArgumentList @($Port, $LoggingPrefix, $VerbosePreference, $importFunctionPath)
}