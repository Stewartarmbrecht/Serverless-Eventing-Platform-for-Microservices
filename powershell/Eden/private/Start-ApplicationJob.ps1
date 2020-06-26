function Start-ApplicationJob
{
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '', Scope='Function')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [String]$Location,
        [Parameter(Mandatory=$TRUE)]
        [Int32]$Port,
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix
    )

    $importFunctionPath = (Join-Path $PSScriptRoot "Import-PrivateFunctions.ps1")

    Start-ThreadJob -Name "rt-Service" -ScriptBlock {
        $VerbosePreference = $args[3]
        . $args[4]
        Start-Application `
            -Location $args[0] `
            -Port $args[1] `
            -LoggingPrefix $args[2]
    } -ArgumentList @($Location, $Port, $LoggingPrefix, $VerbosePreference, $importFunctionPath)
}