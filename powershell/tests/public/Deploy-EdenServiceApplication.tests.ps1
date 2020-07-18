$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

#since we match the srs/tests organization this works
$here = $here -replace 'tests', 'Eden'

. "$here\$sut"    

# Import our module to use InModuleScope
Import-Module (Join-Path $PSScriptRoot "../../Eden/Eden.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "../TestUtilities.psm1") -Force

InModuleScope "Eden" {
    Describe "Public/Deploy-EdenServiceApplication" {
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
                Deploy-EdenServiceApplication -Verbose
                Assert-Logs $log @(
                    "TestSolution TestService Deploy Application TestEnvironment Deploying the application.",
                    "TestSolution TestService Deploy Application TestEnvironment Connecting to the hosting environment.",
                    "TestSolution TestService Deploy Application TestEnvironment Mock: Connect-ServiceHostingEnvironment TestSolution TestService",
                    "TestSolution TestService Deploy Application TestEnvironment Connected to the hosting environment.",
                    "TestSolution TestService Deploy Application TestEnvironment Deploying the service application to staging.",
                    "TestSolution TestService Deploy Application TestEnvironment Mock: Deploy-ServiceAppStaging TestSolution TestService",
                    "TestSolution TestService Deploy Application TestEnvironment Finished deploying the service application to staging.",
                    "TestSolution TestService Deploy Application TestEnvironment Testing the staging instance of the service application.",
                    "TestSolution TestService Deploy Application TestEnvironment Mock: Test-ServiceAppStaging TestSolution TestService",
                    "TestSolution TestService Deploy Application TestEnvironment Finished testing the staging instance of the service application.",
                    "TestSolution TestService Deploy Application TestEnvironment Swapping the staging instance of the service application with the production instance.",
                    "TestSolution TestService Deploy Application TestEnvironment Mock: Invoke-ServiceStagingSwap TestSolution TestService",
                    "TestSolution TestService Deploy Application TestEnvironment Finished swapping the staging instance of the service application with the production instance.",      
                    "TestSolution TestService Deploy Application TestEnvironment Finished deploying the applications."
                )
            }
        }
        Context "When executed with exception thrown" {
            It "Prints the following logs" {
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlockWithError $log)
                {
                    Deploy-EdenServiceApplication -Verbose
                } | Should -Throw                
                Assert-Logs $log @(
                    "TestSolution TestService Deploy Application TestEnvironment Deploying the application.",
                    "TestSolution TestService Deploy Application TestEnvironment Connecting to the hosting environment.",
                    "TestSolution TestService Deploy Application TestEnvironment Mock With Error: Connect-ServiceHostingEnvironment TestSolution TestService",
                    "TestSolution TestService Deploy Application TestEnvironment Error deploying the service application. Message: 'My Error!'"
                )
            }
        }
    }
}