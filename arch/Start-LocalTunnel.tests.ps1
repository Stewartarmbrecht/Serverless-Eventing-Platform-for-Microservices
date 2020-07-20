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
    Describe "Private/Start-LocalTunnel" {
        Context "When executed with success" {
            BeforeEach {
                Mock Invoke-CommandLocalTunnel { }
                Mock Write-EdenBuildInfo

                Start-LocalTunnel -Port 9876 -LoggingPrefix "My Prefix"
            }
            It "Prints the appropriate message to the host." {
                Assert-MockCalled Write-EdenBuildInfo 1 -ParameterFilter { 
                    $Message -eq "Starting the local tunnel to port 9876." `
                    -and `
                    $LoggingPrefix -eq "My Prefix" 
                } 
                Assert-MockCalled Write-EdenBuildInfo 1 -ParameterFilter { 
                    $Message -eq "The service tunnel has been shut down." `
                    -and `
                    $LoggingPrefix -eq "My Prefix" 
                }
            }
            It "Calls the local tunnel command." {
                Assert-MockCalled Invoke-CommandLocalTunnel 1 -ParameterFilter { 
                    $Port -eq 9876 
                }
            }
        }
        Context "When executed with exception" {
            It "Prints the appropriate message to the host and throws the exception." {
                Mock Invoke-CommandLocalTunnel { throw "My error." }
                Mock Write-EdenBuildInfo
                Mock Write-EdenBuildError

                {
                    Start-LocalTunnel -Port 9876 -LoggingPrefix "My Prefix"
                } | Should -Throw

                Assert-MockCalled Write-EdenBuildInfo 1 -ParameterFilter { 
                    $Message -like "Starting the local tunnel to port 9876." `
                    -and `
                    $LoggingPrefix -eq "My Prefix" 
                } 
                Assert-MockCalled Write-EdenBuildError 1 -ParameterFilter {
                    $Message -eq "Exception thrown while starting the local tunnel. Message: 'My error.'" `
                    -and `
                    $LoggingPrefix -eq "My Prefix" 
                }
            }
        }
    }
}