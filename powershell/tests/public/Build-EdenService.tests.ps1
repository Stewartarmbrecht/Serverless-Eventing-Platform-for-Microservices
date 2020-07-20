$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

#since we match the srs/tests organization this works
$here = $here -replace 'tests', 'Eden'

. "$here\$sut"    

# Import our module to use InModuleScope
Import-Module (Join-Path $PSScriptRoot "../../Eden/Eden.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "../TestUtilities.psm1") -Force

InModuleScope "Eden" {
    Describe "Public/Build-EdenService" {
        BeforeEach {
            Mock Get-SolutionName { "TestSolution" }
            Mock Get-ServiceName { "TestService" }
            Set-TestEnvironment
            [System.Collections.ArrayList]$log = @()
            Mock Write-EdenBuildInfo (Get-BuildInfoErrorBlock $log)
            Mock Write-EdenBuildError (Get-BuildInfoErrorBlock $log)
        }
        Context "When executed once successfully" {
            It "Print the following logs" {
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlock $log)
                Build-EdenService -Verbose
                Assert-Logs $log @(
                    "TestSolution TestService Build Building the service.",
                    "TestSolution TestService Build Mock: Build-Service TestSolution TestService",
                    "TestSolution TestService Build Finished building the service."
                )
            }
        }
        Context "When executed continuously successfully" {
            It "Prints the following logs" {
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlock $log)
                Build-EdenService -Continuous -Verbose
                Assert-Logs $log @(
                    "TestSolution TestService Build Building the service continuously.",
                    "TestSolution TestService Build Mock: Build-ServiceContinuous TestSolution TestService"
                )
            }
        }
        Context "When executed with exception thrown" {
            It "Prints the following logs" {
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlockWithError $log)
                {
                    Build-EdenService -Verbose
                } | Should -Throw                
                Assert-Logs $log @(
                    "TestSolution TestService Build Building the service.",
                    "TestSolution TestService Build Mock With Error: Build-Service TestSolution TestService",
                    "TestSolution TestService Build Error building the service. Message: 'My Error!'"
                )
            }
        }
    }
}