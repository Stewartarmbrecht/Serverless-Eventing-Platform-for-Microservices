function Write-EdenError 
{ 
    [CmdletBinding()]
    [Alias("E")]
    param(  
        [Parameter(Mandatory=$true)]
        [String]$value,
        [Parameter(Mandatory=$true)]
        [String]$loggingPrefix
    )
    Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $($loggingPrefix): $value"  -ForegroundColor DarkRed 
}
