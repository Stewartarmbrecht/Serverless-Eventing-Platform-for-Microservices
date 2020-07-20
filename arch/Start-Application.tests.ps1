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
    Describe "Private/Start-Application" {
        BeforeAll {
            Mock Get-SolutionName { "TestSolution" }
            Mock Get-ServiceName { "TestService" }
            Set-TestEnvironment
        }
        Context "When executed with success" {
            It "Prints the appropriate message to the host." {
                Mock Invoke-CommandAppStart { }
                Mock Write-EdenBuildInfo

                Start-Application -Location "." -Port 9876 -LoggingPrefix "My Prefix"

                Assert-MockCalled Write-EdenBuildInfo 2 -ParameterFilter { 
                    $LoggingPrefix -like "My Prefix" 
                }
                Assert-MockCalled Write-EdenBuildInfo 1 -ParameterFilter { 
                    $Message -like "Setting location to '.'."
                } 
                Assert-MockCalled Write-EdenBuildInfo 1 -ParameterFilter { 
                    $Message -like "Running the function application."
                }
            }
        }
        Context "When executed with exception" {
            It "Prints the appropriate message to the host and throws the exception." {
                Mock Invoke-CommandAppStart { throw "My error." }
                Mock Write-EdenBuildInfo
                Mock Write-EdenBuildError

                {
                    Start-Application -Location "." -Port 9876 -LoggingPrefix "My Prefix"
                } | Should -Throw

                Assert-MockCalled Write-EdenBuildInfo 2 -ParameterFilter { 
                    $LoggingPrefix -eq "My Prefix" 
                }
                Assert-MockCalled Write-EdenBuildError 2 -ParameterFilter { 
                    $LoggingPrefix -eq "My Prefix" 
                }
                Assert-MockCalled Write-EdenBuildInfo 1 -ParameterFilter { 
                    $Message -eq "Setting location to '.'."
                } 
                Assert-MockCalled Write-EdenBuildInfo 1 -ParameterFilter { 
                    $Message -eq "Running the function application."
                }
                Assert-MockCalled Write-EdenBuildError 1 -ParameterFilter {
                    $Message -eq "The job threw an exception: 'My error.'."
                }
                Assert-MockCalled Write-EdenBuildError 1 -ParameterFilter {
                    $Message -eq "If you get errno: -4058, try this: https://github.com/Azure/azure-functions-core-tools/issues/1804#issuecomment-594990804"
                }
            }
        }
    }
}