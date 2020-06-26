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
    Describe "Public/Publish-EdenService" {
        BeforeAll {
            Mock Get-SolutionName { "TestSolution" }
            Mock Get-ServiceName { "TestService" }
            Set-TestEnvironment
            Mock Write-BuildInfo {
                param($Message, $LoggingPrefix)
                Write-Verbose "$LoggingPrefix $Message"
            }
            Mock Write-BuildError {
                param($Message, $LoggingPrefix)
                Write-Verbose "$LoggingPrefix $Message"
            }
        }
        Context "When executed successfully" {
            BeforeEach {
                Mock Invoke-CommandPublish { 
                    param($SolutionName, $ServiceName)
                    Write-Verbose "Invoke-CommandPublish -SolutionName $SolutionName -ServiceName $ServiceName"
                }
                Publish-EdenService -Verbose
            }
            It "Executes the publish command" {
                Assert-MockCalled Invoke-CommandPublish 1 -ParameterFilter {
                    $SolutionName -eq "TestSolution" `
                    -and `
                    $ServiceName -eq "TestService"
                } 
            }
            It "Prints a message that it is publishing the service" {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Publishing the service." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Publish"
                }
            }
            It "Prints a message that it is finished publishing the service" {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Finished publishing the service." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Publish"
                }
            }
        }
        Context "When executed with exception thrown" {
            BeforeEach {
                Mock Invoke-CommandPublish { 
                    param($SolutionName, $ServiceName)
                    Write-Verbose "Invoke-CommandPublish -SolutionName $SolutionName -ServiceName $ServiceName"
                    throw "Publish error!"
                }
                {
                    Publish-EdenService -Verbose
                } | Should -Throw                
            }
            It "Invokes the publish command" {
                Assert-MockCalled Invoke-CommandPublish 1 -ParameterFilter {
                    $SolutionName -eq "TestSolution" `
                    -and `
                    $ServiceName -eq "TestService"
                } 
            }
            It "Prints a message that it is publishing the service" {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Publishing the service." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Publish"
                }
            }
            It "Prints a message that publishing threw an exception" {
                Assert-MockCalled Write-BuildError 1 -ParameterFilter {
                    $Message -eq "Error publishing the service. Message: 'Publish error!'" `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Publish"
                }
            }
        }
    }
}