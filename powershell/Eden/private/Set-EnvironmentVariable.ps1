function Set-EnvironmentVariable {
    #[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '', Scope='Function')]
    [CmdletBinding()]
    param(
        [String]$name,
        [String]$value
    ) 
    [System.Environment]::SetEnvironmentVariable($name, $value)
}