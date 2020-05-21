$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

#since we match the srs/tests organization this works
$here = $here -replace 'tests', 'Eden'

. "$here\$sut"

# Import our module to use InModuleScope
Import-Module (Resolve-Path ".\Eden\Eden.psm1") -Force

InModuleScope "Eden" {
    Describe "Private/Get-RandomQuote" {
        # Intentionally Empty.
    }
}