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
    Describe "Private/Test-Automated" {
        Context "When executed with success" {
            BeforeEach {
                Mock Invoke-CommandTestAutomated {
                    # param($SolutionName, $ServiceName)
                    # Write-Verbose $SolutionName
                    # Write-Verbose $ServiceName
                 }
                Mock Write-BuildInfo {
                    # param($Message, $LoggingPrefix)
                    # Write-Verbose $Message
                    # Write-Verbose $LoggingPrefix
                }

                Test-Automated `
                    -SolutionName "My Solution" `
                    -ServiceName "My Service" `
                    -AutomatedUrl "Test Url" `
                    -LoggingPrefix "My Prefix"
            }
            It "Prints the appropriate message to the host." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter { 
                    $Message -eq "Running automated tests against 'Test Url'." `
                    -and `
                    $LoggingPrefix -eq "My Prefix" 
                } 
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter { 
                    $Message -eq "Running automated tests once." `
                    -and `
                    $LoggingPrefix -eq "My Prefix" 
                }
            }
            It "Calls the test automated command." {
                Assert-MockCalled Invoke-CommandTestAutomated 1 -ParameterFilter { 
                    $SolutionName -eq "My Solution" `
                    -and `
                    $ServiceName -eq "My Service" 
                }
            }
        }
        Context "When executed with exception" {
            BeforeEach {
                Mock Invoke-CommandTestAutomated { throw "My error." }
                Mock Write-BuildInfo {
                    # param($Message, $LoggingPrefix)
                    # Write-Verbose $Message
                    # Write-Verbose $LoggingPrefix
                }
                Mock Write-BuildError {
                    # param($Message, $LoggingPrefix)
                    # Write-Verbose $Message
                    # Write-Verbose $LoggingPrefix
                }

                {
                    Test-Automated `
                        -SolutionName "My Solution" `
                        -ServiceName "My Service" `
                        -AutomatedUrl "Test Url" `
                        -LoggingPrefix "My Prefix"
                } | Should -Throw
            }
            It "Prints a message that it is running the automated test against the test url." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter { 
                    $Message -eq "Running automated tests against 'Test Url'." `
                    -and `
                    $LoggingPrefix -eq "My Prefix" 
                } 
            }
            It "Prints a message that it is running the automated tests once." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter { 
                    $Message -eq "Running automated tests once." `
                    -and `
                    $LoggingPrefix -eq "My Prefix" 
                } 
            }
            It "Prints a message that an exception was thrown." {
                Assert-MockCalled Write-BuildError 1 -ParameterFilter {
                    $Message -eq "Exception thrown while executing the automated tests. Message: 'My error.'" `
                    -and `
                    $LoggingPrefix -eq "My Prefix" 
                }
            }
        }
    }
}