[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

    Write-EdenBuildInfo "Starting the ngrok local tunnel to the function application.  Private url: 'http://localhost:7071'." $LoggingPrefix

    $location = Get-Location
    try {
        Set-Location $PSScriptRoot
        if ($IsWindows) {
            ./ngrok.exe http http://localhost:7071 -host-header=rewrite | Write-Verbose
        } else {
            ./ngrok http http://localhost:7071 -host-header=rewrite | Write-Verbose
        }
    } catch {
        throw $_
    } finally {
        Set-Location $location
    }
