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
    Describe "Private/Get-HealthStatus" {
        BeforeAll {
            Mock Get-SolutionName { "TestSolution" }
            Mock Get-ServiceName { "TestService" }
            Set-TestEnvironment
        }
        Context "When executed with a successfull health check" {
            It "Prints the appropriate message to the host." {
                Mock Invoke-RestMethod { @{ status = 0 } }
                Mock Write-BuildInfo
                
                Get-HealthStatus -PublicUrl "MyUrl" -LoggingPrefix "My Prefix"
                
                Assert-MockCalled Write-BuildInfo 2 -ParameterFilter { 
                    $LoggingPrefix -like "My Prefix" 
                }
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter { 
                    $Message -like "Checking API availability at: MyUrl/api/healthcheck?userId=developer98765@test.com" 
                }
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter { 
                    $Message -like "Health check status successful." 
                }
            }
            It "Returns true." {
                Mock Invoke-RestMethod { @{ status = 0 } }
                Mock Write-BuildInfo
                
                $result = Get-HealthStatus -PublicUrl "MyUrl" -LoggingPrefix "My Prefix"
                $result | Should -Be $true
                
            }
        }
        Context "When executed with an unsuccessfull health check" {
            It "Prints the appropriate message to the host." {
                Mock Invoke-RestMethod { @{ status = 9 } }
                Mock Write-BuildInfo

                Get-HealthStatus -PublicUrl "MyUrl" -LoggingPrefix "My Prefix"
                
                Assert-MockCalled Write-BuildInfo 2 -ParameterFilter { 
                    $LoggingPrefix -like "My Prefix" 
                }
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter { 
                    $Message -like "Checking API availability at: MyUrl/api/healthcheck?userId=developer98765@test.com" 
                }
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter { 
                    $Message -like "Health check status unsuccessful. Status: 9" 
                }
            }
            It "Returns false." {
                Mock Invoke-RestMethod { @{ status = 9 } }
                Mock Write-BuildInfo

                $result = Get-HealthStatus -PublicUrl "MyUrl" -LoggingPrefix "My Prefix"
                $result | Should -Be $false                
            }
        }
        Context "When executed with a failed connection" {
            It "Prints the appropriate message to the host." {
                Mock Invoke-RestMethod { throw "MyError!" }
                Mock Write-BuildInfo
                Mock Write-BuildError
                
                Get-HealthStatus -PublicUrl "MyUrl" -LoggingPrefix "My Prefix"
                
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter { 
                    $LoggingPrefix -like "My Prefix" 
                }
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter { 
                    $LoggingPrefix -like "My Prefix" 
                }
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter { 
                    $Message -like "Checking API availability at: MyUrl/api/healthcheck?userId=developer98765@test.com" 
                }
                Assert-MockCalled Write-BuildError 1 -ParameterFilter { 
                    $Message -like "Failed to execute health check: 'MyError!'."
                }
            }
            It "Returns false." {
                Mock Invoke-RestMethod { throw "MyError!" }
                Mock Write-BuildInfo
                
                $result = Get-HealthStatus -PublicUrl "MyUrl" -LoggingPrefix "My Prefix"
                $result | Should -Be $false
                
            }
        }
    }
}