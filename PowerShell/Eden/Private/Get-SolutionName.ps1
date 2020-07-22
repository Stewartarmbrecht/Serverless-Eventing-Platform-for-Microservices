function Get-SolutionName {
    [CmdletBinding()]
    param(
    ) 
    return ((Get-Location) -split '/')[-2]
}