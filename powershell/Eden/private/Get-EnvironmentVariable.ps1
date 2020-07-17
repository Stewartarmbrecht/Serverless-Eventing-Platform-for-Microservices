function Get-EnvironmentVariable {
    #[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '', Scope='Function')]
    [CmdletBinding()]
    param(
        [String]$Name
    ) 
    $result = [System.Environment]::GetEnvironmentVariable($Name)
    return $result
}