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
    Describe "Private/Test-Automated" {
        BeforeAll {
            # Mock Get-SolutionName { "TestSolution" }
            # Mock Get-ServiceName { "TestService" }
            # Set-TestEnvironment
            Mock Write-EdenBuildInfo {
                param($Message, $LoggingPrefix)
                Write-Verbose "$LoggingPrefix $Message"
            }
            Mock Write-EdenBuildError {
                param($Message, $LoggingPrefix)
                Write-Verbose "$LoggingPrefix $Message"
            }
        }
        Context "When executed with success" {
            BeforeEach {
                Mock Invoke-CommandTestAutomated {
                    param($EdenEnvConfig)
                    Write-Verbose "Invoke-CommandTestAutomated $($EdenEnvConfig.SolutionName)  $($EdenEnvConfig.ServiceName)"
                }

                [EdenEnvConfig] $edenEnvConfig = [EdenEnvConfig]::New()
                $edenEnvConfig.EnvironmentName = "TestEnvironment"
                $edenEnvConfig.SolutionName = "TestSolution" 
                $edenEnvConfig.ServiceName = "TestService"
                $edenEnvConfig.ServicePrincipalId = "TestServicePrincipalId"
                $edenEnvConfig.ServicePrincipalPassword = ConvertTo-SecureString "TestServicePrincipalPassword" -AsPlainText
                $edenEnvConfig.TenantId = "TestTenantId"
                $edenEnvConfig.Region = "TestRegion"
                $edenEnvConfig.DeveloperId = "TestDeveloperId"

                Test-Automated -EdenEnvConfig $edenEnvConfig
            }
            It "Prints the appropriate message to the host." {
                Assert-MockCalled Write-EdenBuildInfo 1 -ParameterFilter { 
                    $Message -eq "Running automated tests against the local environment." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Test Automated" 
                } 
                Assert-MockCalled Write-EdenBuildInfo 1 -ParameterFilter { 
                    $Message -eq "Running automated tests once." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Test Automated" 
                }
            }
            It "Calls the test automated command." {
                Assert-MockCalled Invoke-CommandTestAutomated 1 -ParameterFilter { 
                    $EdenEnvConfig.SolutionName -eq "TestSolution" `
                    -and `
                    $EdenEnvConfig.ServiceName -eq "TestService" 
                }
            }
        }
        Context "When executed with exception" {
            BeforeEach {
                Mock Invoke-CommandTestAutomated { 
                    param($EdenEnvConfig)
                    Write-Verbose "Invoke-CommandTestAutomated $($EdenEnvConfig.SolutionName)  $($EdenEnvConfig.ServiceName)"
                    throw "My error." 
                }

                [EdenEnvConfig]$edenEnvConfig = [EdenEnvConfig]::New()
                $edenEnvConfig.EnvironmentName = "TestEnvironment"
                $edenEnvConfig.SolutionName = "TestSolution" 
                $edenEnvConfig.ServiceName = "TestService"
                $edenEnvConfig.ServicePrincipalId = "TestServicePrincipalId"
                $edenEnvConfig.ServicePrincipalPassword = ConvertTo-SecureString "TestServicePrincipalPassword" -AsPlainText
                $edenEnvConfig.TenantId = "TestTenantId"
                $edenEnvConfig.Region = "TestRegion"
                $edenEnvConfig.DeveloperId = "TestDeveloperId"

                {
                    Test-Automated -EdenEnvConfig $edenEnvConfig
                } | Should -Throw
            }
            It "Prints a message that it is running the automated test against the test url." {
                Assert-MockCalled Write-EdenBuildInfo 1 -ParameterFilter { 
                    $Message -eq "Running automated tests against the local environment." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Test Automated" 
                } 
            }
            It "Prints a message that it is running the automated tests once." {
                Assert-MockCalled Write-EdenBuildInfo 1 -ParameterFilter { 
                    $Message -eq "Running automated tests once." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Test Automated" 
                } 
            }
            It "Prints a message that an exception was thrown." {
                Assert-MockCalled Write-EdenBuildError 1 -ParameterFilter {
                    $Message -eq "Exception thrown while executing the automated tests. Message: 'My error.'" `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Test Automated" 
                }
            }
        }
        Context "When executed continuously with success" {
            BeforeEach {
                Mock Invoke-CommandTestAutomatedContinuous {
                    param($EdenEnvConfig)
                    Write-Verbose "Invoke-CommandTestAutomated $($EdenEnvConfig.SolutionName)  $($EdenEnvConfig.ServiceName)"
                }

                [EdenEnvConfig]$edenEnvConfig = [EdenEnvConfig]::New()
                $edenEnvConfig.EnvironmentName = "TestEnvironment"
                $edenEnvConfig.SolutionName = "TestSolution" 
                $edenEnvConfig.ServiceName = "TestService"
                $edenEnvConfig.ServicePrincipalId = "TestServicePrincipalId"
                $edenEnvConfig.ServicePrincipalPassword = ConvertTo-SecureString "TestServicePrincipalPassword" -AsPlainText
                $edenEnvConfig.TenantId = "TestTenantId"
                $edenEnvConfig.Region = "TestRegion"
                $edenEnvConfig.DeveloperId = "TestDeveloperId"

                Test-Automated -EdenEnvConfig $edenEnvConfig -Continuous
            }
            It "Prints the appropriate message to the host." {
                Assert-MockCalled Write-EdenBuildInfo 1 -ParameterFilter { 
                    $Message -eq "Running automated tests against the local environment." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Test Automated" 
                } 
                Assert-MockCalled Write-EdenBuildInfo 1 -ParameterFilter { 
                    $Message -eq "Running automated tests continuously." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Test Automated" 
                }
            }
            It "Calls the test automated command." {
                Assert-MockCalled Invoke-CommandTestAutomatedContinuous 1 -ParameterFilter { 
                    $EdenEnvConfig.SolutionName -eq "TestSolution" `
                    -and `
                    $EdenEnvConfig.ServiceName -eq "TestService" 
                }
            }
        }
    }
}