$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

#since we match the srs/tests organization this works
$here = $here -replace 'tests', 'Eden'

. "$here\$sut"    

# Import our module to use InModuleScope
Import-Module (Join-Path $PSScriptRoot "../../Eden/Eden.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "../TestUtilities.psm1") -Force

InModuleScope "Eden" {
    Describe "Public/Test-EdenServiceCode" {
        BeforeEach {
            Mock Get-SolutionName { "TestSolution" }
            Mock Get-ServiceName { "TestService" }
            Set-TestEnvironment
            [System.Collections.ArrayList]$log = @()
            Mock Write-BuildInfo (Get-BuildInfoErrorBlock $log)
            Mock Write-BuildError (Get-BuildInfoErrorBlock $log)
        }
        Context "When executed once successfully" {
            It "Print the following logs" {
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlock $log)
                Test-EdenServiceCode -Verbose
                Assert-Logs $log @(
                    "TestSolution TestService Test Unit Testing the service code.",
                    "TestSolution TestService Test Unit Mock: Test-ServiceCode TestSolution TestService",
                    "TestSolution TestService Test Unit Finished testing the service code."
                )
            }
        }
        Context "When executed continuously successfully" {
            It "Prints the following logs" {
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlock $log)
                Test-EdenServiceCode -Continuous -Verbose
                Assert-Logs $log @(
                    "TestSolution TestService Test Unit Testing the service code continuously.",
                    "TestSolution TestService Test Unit Mock: Test-ServiceCodeContinuously TestSolution TestService"
                )
            }
        }
        Context "When executed with exception thrown" {
            It "Prints the following logs" {
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlockWithError $log)
                {
                    Test-EdenServiceCode -Verbose
                } | Should -Throw                
                Assert-Logs $log @(
                    "TestSolution TestService Test Unit Testing the service code.",
                    "TestSolution TestService Test Unit Mock With Error: Test-ServiceCode TestSolution TestService",
                    "TestSolution TestService Test Unit Error testing the service code. Message: 'My Error!'"
                )
            }
        }
    }
}