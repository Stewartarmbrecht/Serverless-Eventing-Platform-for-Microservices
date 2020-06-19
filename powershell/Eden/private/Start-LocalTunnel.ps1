function Start-LocalTunnel
{
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '', Scope='Function')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [Int32]$Port,
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix
    )

    Start-Job -Name "rt-Tunnel" -ScriptBlock {
        $port = $args[0]
        $loggingPrefix = $args[1]

        . ./Functions.ps1

        if ($IsWindows) {
            ./ngrok.exe http http://localhost:$port -host-header=rewrite | Write-Verbose
        } else {
            ./ngrok http http://localhost:$port -host-header=rewrite | Write-Verbose
        }

        Write-BuildInfo "The service tunnel is up." $loggingPrefix
    } -ArgumentList @($Port, $LoggingPrefix)
}