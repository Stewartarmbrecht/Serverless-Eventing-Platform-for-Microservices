$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

#since we match the srs/tests organization this works
$here = $here -replace 'tests', 'Eden'

. "$here\$sut"    

# Import our module to use InModuleScope
Import-Module (Join-Path $PSScriptRoot "../../Eden/Eden.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "../TestUtilities.psm1") -Force

InModuleScope "Eden" {
    Describe "Public/Publish-EdenService" {
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
                Publish-EdenService -Verbose
                Assert-Logs $log @(
                    "TestSolution TestService Publish Publishing the service.",
                    "TestSolution TestService Publish Publish-Service TestSolution TestService",
                    "TestSolution TestService Publish Finished publishing the service."
                )
            }
        }
        Context "When executed with exception thrown" {
            It "Prints the following logs" {
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlockWithError $log)
                {
                    Publish-EdenService -Verbose
                } | Should -Throw                
                Assert-Logs $log @(
                    "TestSolution TestService Publish Publishing the service.",
                    "TestSolution TestService Publish Publish-Service TestSolution TestService",
                    "TestSolution TestService Publish Error publishing the service. Message: 'My Error!'"
                )
            }
        }
    }
}