function Write-EdenMessage 
{ 
    [CmdletBinding()]
    [Alias("D")]
    param(
        [Parameter(Mandatory=$true)]
        [String]$value,
        [Parameter(Mandatory=$true)]
        [String]$loggingPrefix
    )
    Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $($loggingPrefix): $value"  -ForegroundColor DarkCyan 
}
