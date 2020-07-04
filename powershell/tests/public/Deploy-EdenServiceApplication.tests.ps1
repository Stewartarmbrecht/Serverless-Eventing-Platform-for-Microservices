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
    Describe "Public/Deploy-EdenServiceApplication" {
        BeforeAll {
            Mock Get-SolutionName { "TestSolution" }
            Mock Get-ServiceName { "TestService" }
            Set-TestEnvironment
        }
        Context "When executed successfully" {
            BeforeAll {
                [System.Collections.ArrayList]$log = @()
                Mock Write-BuildInfo {
                    param($Message, $LoggingPrefix)
                    $logEntry = "$LoggingPrefix $Message"
                    Write-Verbose $logEntry
                    $log.Add($logEntry)
                }
                # Mock Write-BuildInfo -MockWith (Get-MockWriteBuildInfoBlock -Log $log)
                Mock Invoke-CommandConnect {
                    param($UserId, [SecureString]$Password, $TenantId)
                    $logEntry = "Invoke-CommandConnect $UserId $($Password.Length -gt 0) $TenantId"
                    Write-Verbose $logEntry
                    $log.Add($logEntry)
                }
                Connect-HostingEnvironment -LoggingPrefix "TestLoggingPrefix"
            }
            It "Prints a message that it is starting the application deployment" {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Deploying the service infrastructure." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Deploy Infrastructure TestInstance"
                }
            }
            It "Prints a message that it is connecting to the hosting environment" {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Deploying the service infrastructure." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Deploy Infrastructure TestInstance"
                }
            }
            It "Invokes the command to connect to the hosting environment" {
                Assert-MockCalled Connect-AzureServicePrincipal 1 -ParameterFilter {
                    $LoggingPrefix -eq "TestSolution TestService Deploy Infrastructure TestInstance"
                } 
            }
            It "Prints a message that it is deploying the application to the staging environment" {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Creating the resource group: testinstance-testservice." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Deploy Infrastructure TestInstance"
                }
            }
            It "Invokes the command to deploy the application" {
                Assert-MockCalled New-AzResourceGroup 1 -ParameterFilter {
                    $Name -eq "testinstance-testservice" `
                    -and `
                    $Location -eq "TestRegion" `
                    -and `
                    $Force -eq $TRUE
                } 
            }
            It "Prints a message that it is running the automated tests against staging." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Executing the deployment using: ./Infrastructure/Infrastructure.json." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Deploy Infrastructure TestInstance"
                }
            }
            It "Invokes the command to execute automated tests against the staging environment" {
                Assert-MockCalled New-AzResourceGroupDeployment 1 -ParameterFilter {
                    $ResourceGroupName -eq "testinstance-testservice" `
                    -and `
                    $TemplateFile -eq "./Infrastructure/Infrastructure.json" `
                    -and `
                    $TemplateParameterObject.InstanceName -eq "TestInstance"
                } 
            }
            It "Prints a message that it is switching the staging environment with production " {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Deployed the service infrastructure." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Deploy Infrastructure TestInstance"
                }
            }
            It "Invokes the command to switch staging with production" {
                Assert-MockCalled New-AzResourceGroupDeployment 1 -ParameterFilter {
                    $ResourceGroupName -eq "testinstance-testservice" `
                    -and `
                    $TemplateFile -eq "./Infrastructure/Infrastructure.json" `
                    -and `
                    $TemplateParameterObject.InstanceName -eq "TestInstance"
                } 
            }
            It "Prints a message that it has finished deploying the application" {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Deployed the service infrastructure." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Deploy Infrastructure TestInstance"
                }
            }
        }
    }
}