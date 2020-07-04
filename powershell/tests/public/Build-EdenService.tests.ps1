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
    Describe "Public/Build-EdenService" {
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
        Context "When executed once successfully" {
            BeforeEach {
                Mock Invoke-CommandBuild { 
                    Write-Verbose "Build ran successfully." 
                }
                {
                    Build-EdenService -Verbose
                } | Should -Not -Throw                
            }
            It "Invokes the build command" {
                Assert-MockCalled Invoke-CommandBuild 1 -ParameterFilter {
                    $EdenEnvConfig.SolutionName -eq "TestSolution" `
                    -and `
                    $EdenEnvConfig.ServiceName -eq "TestService"
                } 
            }
            It "Prints a message that it is building the service" {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Building the service." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Build"
                }
            }
            It "Prints a message that it is finished building the service" {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Finished building the service." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Build"
                }
            }
        }
        Context "When executed continuously successfully" {
            BeforeEach {
                Mock Invoke-CommandBuildContinuous { 
                    Write-Verbose "Build running successfully continuously." 
                }
                {
                    Build-EdenService -Continuous -Verbose
                } | Should -Not -Throw                
            }
            It "Invokes the build command with continuous switch" {
                Assert-MockCalled Invoke-CommandBuildContinuous 1 -ParameterFilter {
                    $EdenEnvConfig.SolutionName -eq "TestSolution" `
                    -and `
                    $EdenEnvConfig.ServiceName -eq "TestService"
                } 
            }
            It "Prints a message that it is building the service continuously" {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Building the service continuously." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Build"
                }
            }
        }
        Context "When executed with exception thrown" {
            BeforeEach {
                Mock Invoke-CommandBuild { 
                    throw "Build error!" 
                }
                {
                    Build-EdenService -Verbose
                } | Should -Throw                
            }
            It "Invokes the build command" {
                Assert-MockCalled Invoke-CommandBuild 1 -ParameterFilter {
                    $EdenEnvConfig.SolutionName -eq "TestSolution" `
                    -and `
                    $EdenEnvConfig.ServiceName -eq "TestService"
                } 
            }
            It "Prints a message that it is building the service" {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Building the service." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Build"
                }
            }
            It "Prints a message that the build threw and exception" {
                Assert-MockCalled Write-BuildError 1 -ParameterFilter {
                    $Message -eq "Error building the service. Message: 'Build error!'" `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Build"
                }
            }
        }
    }
}