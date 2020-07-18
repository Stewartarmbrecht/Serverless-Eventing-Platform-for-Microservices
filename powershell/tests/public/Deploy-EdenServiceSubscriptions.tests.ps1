$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

#since we match the srs/tests organization this works
$here = $here -replace 'tests', 'Eden'

. "$here\$sut"    

# Import our module to use InModuleScope
Import-Module (Join-Path $PSScriptRoot "../../Eden/Eden.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "../TestUtilities.psm1") -Force

InModuleScope "Eden" {
    Describe "Public/Deploy-EdenServiceSubscriptions" {
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
                Deploy-EdenServiceSubscriptions -Verbose
                Assert-Logs $log @(
                    "TestSolution TestService Deploy Subscriptions TestEnvironment Deploying the service subscriptions.",
                    "TestSolution TestService Deploy Subscriptions TestEnvironment Mock: Deploy-ServiceSubscriptions TestSolution TestService",
                    "TestSolution TestService Deploy Subscriptions TestEnvironment Finished deploying the service subscriptions."
                )
            }
        }
        Context "When executed with exception thrown" {
            It "Prints the following logs" {
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlockWithError $log)
                {
                    Deploy-EdenServiceSubscriptions -Verbose
                } | Should -Throw                
                Assert-Logs $log @(
                    "TestSolution TestService Deploy Subscriptions TestEnvironment Deploying the service subscriptions.",
                    "TestSolution TestService Deploy Subscriptions TestEnvironment Mock With Error: Deploy-ServiceSubscriptions TestSolution TestService",
                    "TestSolution TestService Deploy Subscriptions TestEnvironment Error deploying the service subscriptions. Message: 'My Error!'"
                )
            }
        }
    }
}