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
    Describe "Private/Get-PublicUrl" {
        BeforeAll {
            Mock Get-SolutionName { "TestSolution" }
            Mock Get-ServiceName { "TestService" }
            Set-TestEnvironment
        }
        Context "When executed with success" {
            It "Prints the appropriate message to the host." {
                Mock Invoke-RestMethod { 
                    @{ 
                        tunnels = @{
                            proto = "https"
                            public_url = "MyPublicUrl"
                            config = @{
                                addr = "http://localhost:9876"
                            }
                        } 
                    } 
                }
                Mock Write-EdenBuildInfo
                
                Get-PublicUrl -Port 9876 -LoggingPrefix "My Prefix"
                
                Assert-MockCalled Write-EdenBuildInfo 2 -ParameterFilter { 
                    $LoggingPrefix -like "My Prefix" 
                }
                Assert-MockCalled Write-EdenBuildInfo 1 -ParameterFilter { 
                    $Message -like "Calling the ngrok API to get the public url to port '9876'."
                } 
                Assert-MockCalled Write-EdenBuildInfo 1 -ParameterFilter { 
                    $Message -like "Found the public URL: 'MyPublicUrl' for private URL: 'http://localhost:9876'." 
                }
            }
            It "Returns true." {
                Mock Invoke-RestMethod { 
                    @{ 
                        tunnels = @{
                            proto = "https"
                            public_url = "MyPublicUrl"
                            config = @{
                                addr = "http://localhost:9876"
                            }
                        } 
                    } 
                }
                Mock Write-EdenBuildInfo
                
                $result = Get-PublicUrl -Port 9876 -LoggingPrefix "My Prefix"
                
                $result | Should -Be "MyPublicUrl"
            }
        }
        Context "When executed with an unsuccessfull attempt" {
            It "Prints the appropriate message to the host." {
                Mock Invoke-RestMethod { Throw "MyError" }
                Mock Write-EdenBuildInfo
                Mock Write-EdenBuildError

                Get-PublicUrl -Port 9876 -LoggingPrefix "My Prefix"
                
                Assert-MockCalled Write-EdenBuildInfo 1 -ParameterFilter { 
                    $LoggingPrefix -like "My Prefix" 
                }
                Assert-MockCalled Write-EdenBuildError 1 -ParameterFilter { 
                    $LoggingPrefix -like "My Prefix" 
                }
                Assert-MockCalled Write-EdenBuildInfo 1 -ParameterFilter { 
                    $Message -like "Calling the ngrok API to get the public url to port '9876'."
                }
                Assert-MockCalled Write-EdenBuildError 1 -ParameterFilter { 
                    $Message -like "Failed to get the public url: 'MyError'."
                }
            }
            It "Returns an empty string." {
                Mock Invoke-RestMethod { throw "MyError" }
                Mock Write-EdenBuildInfo
                Mock Write-EdenBuildError

                $result = Get-PublicUrl -Port 9876 -LoggingPrefix "My Prefix"
                $result | Should -Be ""                
            }
        }
    }
}