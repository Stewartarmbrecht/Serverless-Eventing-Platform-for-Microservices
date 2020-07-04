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
    Describe "Public/Test-EdenServiceUnit" {
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
        Context "When executed once successfully" {
            BeforeEach {
                Mock Invoke-CommandTestUnit { 
                    Write-Verbose "Unit tests ran successfully." 
                }
                {
                    Test-EdenServiceUnit -Verbose
                } | Should -Not -Throw                
            }
            It "Invokes the unit test command" {
                Assert-MockCalled Invoke-CommandTestUnit 1 -ParameterFilter {
                    $EdenEnvConfig.SolutionName -eq "TestSolution" `
                    -and `
                    $EdenEnvConfig.ServiceName -eq "TestService"
                } 
            }
            It "Prints a message that it is unit testing the service" {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Running the unit tests." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Test Unit"
                }
            }
            It "Prints a message that it is finished unit testing the service" {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Finished running the unit tests." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Test Unit"
                }
            }
        }
        Context "When executed continuously successfully" {
            BeforeEach {
                Mock Invoke-CommandTestUnitContinuous { 
                    Write-Verbose "Unit tests running successfully continuously." 
                }
                {
                    Test-EdenServiceUnit -Continuous -Verbose
                } | Should -Not -Throw                
            }
            It "Invokes the unit test command with continuous switch" {
                Assert-MockCalled Invoke-CommandTestUnitContinuous 1 -ParameterFilter {
                    $EdenEnvConfig.SolutionName -eq "TestSolution" `
                    -and `
                    $EdenEnvConfig.ServiceName -eq "TestService"
                } 
            }
            It "Prints a message that it is unit testing the service continuously" {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Running the unit tests continuously." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Test Unit"
                }
            }
        }
        Context "When executed with exception thrown" {
            BeforeEach {
                Mock Invoke-CommandTestUnit { 
                    throw "Unit test error!" 
                }
                {
                    Test-EdenServiceUnit -Verbose
                } | Should -Throw                
            }
            It "Invokes the unit test command" {
                Assert-MockCalled Invoke-CommandTestUnit 1 -ParameterFilter {
                    $EdenEnvConfig.SolutionName -eq "TestSolution" `
                    -and `
                    $EdenEnvConfig.ServiceName -eq "TestService"
                } 
            }
            It "Prints a message that it is unit testing the service" {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Running the unit tests." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Test Unit"
                }
            }
            It "Prints a message that the unit tests threw and exception" {
                Assert-MockCalled Write-BuildError 1 -ParameterFilter {
                    $Message -eq "Error unit testing the service. Message: 'Unit test error!'" `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Test Unit"
                }
            }
        }
    }
}