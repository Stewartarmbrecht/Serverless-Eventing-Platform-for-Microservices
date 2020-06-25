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
    Describe "Private/Test-AutomatedJob" {
        BeforeAll {
            Mock Get-SolutionName { "TestSolution" }
            Mock Get-ServiceName { "TestService" }
            Set-TestEnvironment
        }
        Context "When executed with success" {
            BeforeEach {
                Mock Test-Automated {}

                Mock Start-ThreadJob { 
                    param ([String]$Name, [ScriptBlock]$ScriptBlock, $ArgumentList) 
                    Invoke-Command $ScriptBlock -ArgumentList $ArgumentList
                }
    
                Test-AutomatedJob `
                    -SolutionName "My Solution" `
                    -ServiceName "My Service" `
                    -AutomatedUrl "Test Url" `
                    -LoggingPrefix "My Prefix"
            }
            It "Calls Start-LocalTunnel" {
                Assert-MockCalled Test-Automated 1 -ParameterFilter { 
                    $SolutionName -eq "My Solution" `
                    -and `
                    $ServiceName -eq "My Service" `
                    -and `
                    $AutomatedUrl -eq "Test Url" `
                    -and `
                    $LoggingPrefix -eq "My Prefix"
                }
            }
        }
        Context "When executed continuous with success" {
            BeforeEach {
                Mock Test-Automated {}

                Mock Start-ThreadJob { 
                    param ([String]$Name, [ScriptBlock]$ScriptBlock, $ArgumentList) 
                    Invoke-Command $ScriptBlock -ArgumentList $ArgumentList
                }
    
                Test-AutomatedJob `
                    -SolutionName "My Solution" `
                    -ServiceName "My Service" `
                    -AutomatedUrl "Test Url" `
                    -LoggingPrefix "My Prefix" `
                    -Continuous
            }
            It "Calls Start-LocalTunnel" {
                Assert-MockCalled Test-Automated 1 -ParameterFilter { 
                    $SolutionName -eq "My Solution" `
                    -and `
                    $ServiceName -eq "My Service" `
                    -and `
                    $AutomatedUrl -eq "Test Url" `
                    -and `
                    $LoggingPrefix -eq "My Prefix" `
                    -and `
                    $Continuous -eq $true
                }
            }
        }
    }
}