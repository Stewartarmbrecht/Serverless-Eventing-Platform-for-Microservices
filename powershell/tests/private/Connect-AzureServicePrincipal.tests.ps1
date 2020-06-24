$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

#since we match the srs/tests organization this works
$here = $here -replace 'tests', 'Eden'

. "$here\$sut"    

# Import our module to use InModuleScope
$modulePath = Join-Path $PSScriptRoot "../../Eden/Eden.psm1"
Import-Module $modulePath -Force
Write-Host (Get-Location)
Import-Module (Join-Path $PSScriptRoot "../TestUtilities.psm1") -Force

InModuleScope "Eden" {
    Describe "Private/Connect-AzureServicePrincipal" {
        BeforeAll {
            Mock Get-SolutionName { "TestSolution" }
            Mock Get-ServiceName { "TestService" }
            Set-TestEnvironment
        }
        Context "When executed successfully" {
            It "Prints the appropriate message to the host." {
                Mock Connect-AzAccount
                Mock Write-BuildInfo
                
                Connect-AzureServicePrincipal -LoggingPrefix "TestSolution TestService Testing TestInstance"
                
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter { $Message -like "*Connecting to service principal: TestUserId on tenant: TestTenant*" }
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter { $LoggingPrefix -like "*TestSolution TestService Testing TestInstance*" }
            }
            It "Returns the connection output when set to Verbose." {
                Mock Connect-AzAccount { return @{ MyTest = "Testing" } }
                Mock Write-BuildInfo
                
                $result = Connect-AzureServicePrincipal -LoggingPrefix "TestSolution TestService Testing TestInstance" -Verbose
                
                $result.MyTest | Should -Be "Testing"
            }
        }
        Context "When experiences an error" {
            It "Throws the error." {
                Mock Connect-AzAccount { throw "I'm an error!!" }
                Mock Write-BuildInfo
                {
                    Connect-AzureServicePrincipal `
                        -LoggingPrefix "TestSolution TestService Testing TestInstance" `

                } | Should -Throw "I'm an error!!"
            }
        }
    }
}