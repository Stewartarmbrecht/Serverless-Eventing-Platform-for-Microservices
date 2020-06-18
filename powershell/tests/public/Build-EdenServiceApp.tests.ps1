$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

#since we match the srs/tests organization this works
$here = $here -replace 'tests', 'Eden'

. "$here\$sut"

# Import our module to use InModuleScope
Import-Module (Resolve-Path ".\Eden\Eden.psm1") -Force

InModuleScope "Eden" {
    Describe "Public/Build-EdenApplication" {
        Context "Once" {
            $currentLocation = Get-Location
            It "Builds the application" {
                $currentLocation = Get-Location
                Set-Location "../ContentReactor/Health/"
                {Build-EdenServiceApp -Verbose} | Should -Not -Throw
                Set-Location $currentLocation
            }
            It "Throws an error if the project is missing" {
                $currentLocation = Get-Location
                Set-Location "../"
                {Build-EdenServiceApp -Verbose } | Should -Throw
                Set-Location $currentLocation
            }
        }
    }
}