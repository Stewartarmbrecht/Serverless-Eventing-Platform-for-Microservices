$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

#since we match the srs/tests organization this works
$here = $here -replace 'tests', 'Eden'

. "$here\$sut"    

# Import our module to use InModuleScope
$modulePath = Join-Path $PSScriptRoot "../../Eden/Eden.psm1"
Import-Module $modulePath -Force
Import-Module (Join-Path $PSScriptRoot "../TestUtilities.psm1") -Force

InModuleScope "Eden" {
    Describe "Public/$sut" {
        BeforeAll {
            Mock Get-SolutionName { "TestSolution" }
            Mock Get-ServiceName { "TestService" }
            Set-TestEnvironment
            Mock Write-BuildInfo {
                param($Message, $LoggingPrefix)
                Write-Verbose "$LoggingPrefix $Message"
            }
            Mock Write-BuildError {
                param($Message, $LoggingPrefix)
                Write-Verbose "$LoggingPrefix $Message"
            }
        }
        Context "When executed successfully once" {
            BeforeEach {
                Mock Start-EdenServiceLocal { }
                Test-EdenServiceAutomated -Verbose
            }
            It "Calls the Start-EdenServiceLocal command with the RunAutomatedTests switch." {
                Assert-MockCalled Start-EdenServiceLocal 1 -ParameterFilter {
                    $RunAutomatedTests -eq $true
                }
            }
            It "Prints a message that it is running automated tests." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Running automated tests." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Test Automated TestInstance"
                }
            }
            It "Prints a message that it is finished running automated tests." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Finished running automated tests." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Test Automated TestInstance"
                }
            }
        }
        Context "When executed successfully continuously" {
            BeforeEach {
                Mock Start-EdenServiceLocal { }
                Test-EdenServiceAutomated -Continuous -Verbose
            }
            It "Calls the Start-EdenServiceLocal command with the RunAutomatedTestsContinuously switch." {
                Assert-MockCalled Start-EdenServiceLocal 1 -ParameterFilter {
                    $RunAutomatedTestsContinuously -eq $true
                }
            }
            It "Prints a message that it is running automated tests continuously." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Running automated tests continuously." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Test Automated TestInstance"
                }
            }
        }
        Context "When executed with tests failing" {
            BeforeEach {
                Mock Start-EdenServiceLocal { throw "Tests failed." }
                {
                    Test-EdenServiceAutomated -Verbose                    
                } | Should -Throw
            }
            It "Calls the Start-EdenServiceLocal command with the RunAutomatedTests switch." {
                Assert-MockCalled Start-EdenServiceLocal 1 -ParameterFilter {
                    $RunAutomatedTests -eq $true
                }
            }
            It "Prints a message that it is running automated tests." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Running automated tests." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Test Automated TestInstance"
                }
            }
            It "Prints a message that it there was an exception running the automated tests." {
                Assert-MockCalled Write-BuildError 1 -ParameterFilter {
                    $Message -eq "Error running automated tests.  Message: 'Tests failed.'" `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Test Automated TestInstance"
                }
            }
        }
    }
}