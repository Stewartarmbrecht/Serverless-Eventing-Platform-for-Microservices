[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

    Write-EdenBuildInfo "Starting the ngrok local tunnel to the function application.  Private url: 'http://localhost:7071'." $LoggingPrefix

    $location = Get-Location
    try {
        if ($IsWindows) {
            Set-Location $PSScriptRoot/Windows
            ./ngrok.exe http http://localhost:7071 -host-header=rewrite | Write-Verbose
        } 
        if ($IsMacOS) {
            Set-Location $PSScriptRoot/Mac
            ./ngrok http http://localhost:7071 -host-header=rewrite | Write-Verbose
        }
        if ($IsLinux) {
            Set-Location $PSScriptRoot/Linux
            ./ngrok http http://localhost:7071 -host-header=rewrite | Write-Verbose
        }
    } catch {
        throw $_
    } finally {
        Set-Location $location
    }
