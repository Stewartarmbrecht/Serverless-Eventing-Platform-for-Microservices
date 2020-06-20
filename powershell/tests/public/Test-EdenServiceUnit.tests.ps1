$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

#since we match the srs/tests organization this works
$here = $here -replace 'tests', 'Eden'

. "$here\$sut"    

# Import our module to use InModuleScope
Import-Module (Resolve-Path ".\Eden\Eden.psm1") -Force

InModuleScope "Eden" {
    Describe "Public/Test-EdenServiceUnit" {
        Context "When executed only once" {
            It "Executes successfully for a unit test run without error." {
                Mock Invoke-TestUnitCommand { 
                    Write-Verbose "Unit tests ran successfully." 
                }
                
                {
                    Test-EdenServiceUnit -Verbose
                } | Should -Not -Throw
            }
            It "Throws an error for a failed unit test run." {
                Mock Invoke-TestUnitCommand { 
                    Write-Host "Test run failed."
                    throw "Unit testing the solution exited with an error."
                }
                {
                    Test-EdenServiceUnit -Verbose 
                } | Should -Throw
            }
        }
        Context "Continuously" {
            It "Executes successfully" {
                Mock Invoke-ContinuousTestUnitCommand { 
                    Write-Verbose "Unit tests ran successfully." 
                }
                {
                    Test-EdenServiceUnit -Continuous -Verbose
                } | Should -Not -Throw
            }
            It "Throws an error if the project is missing" {
                Mock Invoke-ContinuousTestUnitCommand { 
                    Write-Host "Cannot find project."
                    throw "Unit testing the solution exited with an error."
                }
                {
                    Test-EdenServiceUnit -Continuous -Verbose
                } | Should -Throw
            }
        }
    }
}