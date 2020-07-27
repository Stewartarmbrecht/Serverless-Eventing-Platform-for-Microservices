function Write-EdenBuildError {
    #[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '', Scope='Function')]
    [CmdletBinding()]
    param(
        [Alias("m")]
        [String]$Message,
        [Alias("lp")]
        [String]$LoggingPrefix
    ) 
    Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $($LoggingPrefix): $Message" -ForegroundColor DarkRed 
}
New-Alias `
    -Name e-uwe `
    -Value Write-EdenBuildError
