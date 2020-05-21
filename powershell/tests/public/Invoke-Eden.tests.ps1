$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

#since we match the srs/tests organization this works
$here = $here -replace 'tests', 'Eden'

. "$here\$sut"

# Import our module to use InModuleScope
Import-Module (Resolve-Path ".\Eden\Eden.psm1") -Force

InModuleScope "Eden" {
    Describe "Public/Invoke-Eden" {
        Context "Ask" {
            It "Asks a question" {
                {Invoke-Eden -Ask "Is the cake a lie?" } | Should Not Throw
            }
            It "specifies a format" {
                {Invoke-Eden -Ask "Is the cake a lie?" -Format integer } | Should Not Throw
            }
        }
        Context "Help" {
            It "gets the docs" {
                {Invoke-Eden -Help } | Should Not Throw
            }
        }
    }
}