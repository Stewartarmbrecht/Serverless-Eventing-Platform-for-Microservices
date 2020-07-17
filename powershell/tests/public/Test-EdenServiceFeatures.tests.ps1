$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

#since we match the srs/tests organization this works
$here = $here -replace 'tests', 'Eden'

. "$here\$sut"    

# Import our module to use InModuleScope
Import-Module (Join-Path $PSScriptRoot "../../Eden/Eden.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "../TestUtilities.psm1") -Force

InModuleScope "Eden" {
    Describe "Public/Test-EdenServiceFeatures" {
        Context "When executed with default parameters" {
            It "Calls the Start-EdenServiceLocal command with run feature tests true" {
                Mock Start-EdenServiceLocal {
                    Write-Verbose "Continuous: $Continuous RunFeatureTests: $RunFeatureTests RunFeatureTestsContinuously: $RunFeatureTestsContinuously"                    
                }
                Test-EdenServiceFeatures
                Assert-MockCalled "Start-EdenServiceLocal" -Times 1 -ParameterFilter {
                    $Continuous -eq $false `
                    -and `
                    $RunFeatureTests -eq $true `
                    -and `
                    $RunFeatureTestsContinuously -eq $false
                }
            }
        }
        Context "When executed continuously" {
            It "Calls the Start-EdenServiceLocal command with continuous build and continuous feature tests" {
                Mock Start-EdenServiceLocal {
                    Write-Verbose "Continuous: $Continuous RunFeatureTests: $RunFeatureTests RunFeatureTestsContinuously: $RunFeatureTestsContinuously"                    
                }
                Test-EdenServiceFeatures -Continuous
                Assert-MockCalled "Start-EdenServiceLocal" -Times 1 -ParameterFilter {
                    $Continuous -eq $true `
                    -and `
                    $RunFeatureTests -eq $false `
                    -and `
                    $RunFeatureTestsContinuously -eq $true
                }
            }
        }
        Context "When executed continuously with build once" {
            It "Calls the Start-EdenServiceLocal command with continuous false and run features continuously" {
                Mock Start-EdenServiceLocal {
                    Write-Verbose "Continuous: $Continuous RunFeatureTests: $RunFeatureTests RunFeatureTestsContinuously: $RunFeatureTestsContinuously"                    
                }
                Test-EdenServiceFeatures -Continuous -BuildOnce
                Assert-MockCalled "Start-EdenServiceLocal" -Times 1 -ParameterFilter {
                    $Continuous -eq $false `
                    -and `
                    $RunFeatureTests -eq $false `
                    -and `
                    $RunFeatureTestsContinuously -eq $true
                }
            }
        }
    }
}