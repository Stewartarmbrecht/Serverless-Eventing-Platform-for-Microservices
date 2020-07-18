$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

#since we match the srs/tests organization this works
$here = $here -replace 'tests', 'Eden'

. "$here\$sut"    

# Import our module to use InModuleScope
Import-Module (Join-Path $PSScriptRoot "../../Eden/Eden.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "../TestUtilities.psm1") -Force

InModuleScope "Eden" {
    Describe "Public/Deploy-EdenServiceInfrastructure" {
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
                Deploy-EdenServiceInfrastructure -Verbose
                Assert-Logs $log @(
                    "TestSolution TestService Deploy Infrastructure TestEnvironment Deploying the service infrastructure.",
                    "TestSolution TestService Deploy Infrastructure TestEnvironment Mock: Deploy-ServiceInfrastructure TestSolution TestService",
                    "TestSolution TestService Deploy Infrastructure TestEnvironment Finished deploying the service infrastructure."
                )
            }
        }
        Context "When executed with exception thrown" {
            It "Prints the following logs" {
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlockWithError $log)
                {
                    Deploy-EdenServiceInfrastructure -Verbose
                } | Should -Throw                
                Assert-Logs $log @(
                    "TestSolution TestService Deploy Infrastructure TestEnvironment Deploying the service infrastructure.",
                    "TestSolution TestService Deploy Infrastructure TestEnvironment Mock With Error: Deploy-ServiceInfrastructure TestSolution TestService",
                    "TestSolution TestService Deploy Infrastructure TestEnvironment Error deploying the service infrastructure. Message: 'My Error!'"
                )
            }
        }
    }
}