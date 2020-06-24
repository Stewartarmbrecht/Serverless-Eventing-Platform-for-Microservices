function Get-ServiceName {
    [CmdletBinding()]
    param(
    ) 
    return ((Get-Location) -split '\\')[-1]
}