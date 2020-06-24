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
    Describe "Private/Start-LocalTunnelJob" {
        BeforeAll {
            Mock Get-SolutionName { "TestSolution" }
            Mock Get-ServiceName { "TestService" }
            Set-TestEnvironment
        }
        Context "When executed with success" {
            BeforeEach {
                Mock Start-LocalTunnel {}

                Mock Start-ThreadJob { 
                    param ([String]$Name, [ScriptBlock]$ScriptBlock, $ArgumentList) 
                    Invoke-Command $ScriptBlock -ArgumentList $ArgumentList
                }
    
                Start-LocalTunnelJob -Port 9876 -LoggingPrefix "My Prefix"    
            }
            It "Calls Start-LocalTunnel" {
                Assert-MockCalled Start-LocalTunnel 1 -ParameterFilter { 
                    $Port -eq 9876 -and $LoggingPrefix -eq "My Prefix"
                }
            }
        }
    }
}