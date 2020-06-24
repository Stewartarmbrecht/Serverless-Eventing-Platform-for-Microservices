function Get-EnvironmentVariable {
    #[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '', Scope='Function')]
    [CmdletBinding()]
    param(
        [String]$name
    ) 
    [System.Environment]::GetEnvironmentVariable($name)
}