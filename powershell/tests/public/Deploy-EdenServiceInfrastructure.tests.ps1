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
    Describe "Public/Deploy-EdenServiceInfrastructure" {
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
            Mock Connect-AzureServicePrincipal {
                param($LoggingPrefix)
                Write-Verbose "Connect-AzureServicePrincipal -LoggingPrefix $LoggingPrefix"
            }
            Mock New-AzResourceGroup {
                param($Name, $Location, $Force)
                Write-Verbose "New-AzResourceGroup -Name $Name -Location $Location -Force:$Force"
            }
        }
        Context "When executed successfully" {
            BeforeEach {
                Mock New-AzResourceGroupDeployment {
                    param($ResourceGroupName, $TemplateFile, $InstanceName)
                    Write-Verbose "New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -InstanceName $InstanceName"
                }
                Deploy-EdenServiceInfrastructure -Verbose
            }
            It "Prints a message that it is deploying the service infrastructure" {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Deploying the service infrastructure." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Deploy Infrastructure TestInstance"
                }
            }
            It "Executes the azure connect command" {
                Assert-MockCalled Connect-AzureServicePrincipal 1 -ParameterFilter {
                    $LoggingPrefix -eq "TestSolution TestService Deploy Infrastructure TestInstance"
                } 
            }
            It "Prints a message that it is creating the resource group." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Creating the resource group: testinstance-testservice." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Deploy Infrastructure TestInstance"
                }
            }
            It "Executes the azure group create command" {
                Assert-MockCalled New-AzResourceGroup 1 -ParameterFilter {
                    $Name -eq "testinstance-testservice" `
                    -and `
                    $Location -eq "TestRegion" `
                    -and `
                    $Force -eq $TRUE
                } 
            }
            It "Prints a message that it is executing the deployment." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Executing the deployment using: ./Infrastructure/Infrastructure.json." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Deploy Infrastructure TestInstance"
                }
            }
            It "Executes the azure deployment create command" {
                Assert-MockCalled New-AzResourceGroupDeployment 1 -ParameterFilter {
                    $ResourceGroupName -eq "testinstance-testservice" `
                    -and `
                    $TemplateFile -eq "./Infrastructure/Infrastructure.json" `
                    -and `
                    $TemplateParameterObject.InstanceName -eq "TestInstance"
                } 
            }
            It "Prints a message that it is finished deploying the service infrastructure" {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Deployed the service infrastructure." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Deploy Infrastructure TestInstance"
                }
            }
        }
        Context "When executed with an exception" {
            BeforeEach {
                Mock New-AzResourceGroupDeployment {
                    param($ResourceGroupName, $TemplateFile, $InstanceName)
                    Write-Verbose "New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -InstanceName $InstanceName"
                    throw "My Error!"
                }
                {
                    Deploy-EdenServiceInfrastructure -Verbose                    
                } | Should -Throw
            }
            It "Prints a message that it is deploying the service infrastructure" {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Deploying the service infrastructure." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Deploy Infrastructure TestInstance"
                }
            }
            It "Executes the azure connect command" {
                Assert-MockCalled Connect-AzureServicePrincipal 1 -ParameterFilter {
                    $LoggingPrefix -eq "TestSolution TestService Deploy Infrastructure TestInstance"
                } 
            }
            It "Prints a message that it is creating the resource group." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Creating the resource group: testinstance-testservice." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Deploy Infrastructure TestInstance"
                }
            }
            It "Executes the azure group create command" {
                Assert-MockCalled New-AzResourceGroup 1 -ParameterFilter {
                    $Name -eq "testinstance-testservice" `
                    -and `
                    $Location -eq "TestRegion" `
                    -and `
                    $Force -eq $TRUE
                } 
            }
            It "Prints a message that it is executing the deployment." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Executing the deployment using: ./Infrastructure/Infrastructure.json." `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Deploy Infrastructure TestInstance"
                }
            }
            It "Executes the azure deployment create command" {
                Assert-MockCalled New-AzResourceGroupDeployment 1 -ParameterFilter {
                    $ResourceGroupName -eq "testinstance-testservice" `
                    -and `
                    $TemplateFile -eq "./Infrastructure/Infrastructure.json" `
                    -and `
                    $TemplateParameterObject.InstanceName -eq "TestInstance"
                } 
            }
            It "Prints a message that it experienced an error deploying the infrastructure" {
                Assert-MockCalled Write-BuildError 1 -ParameterFilter {
                    $Message -eq "Error deploying the service infrastructure. Message: 'My Error!'" `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Deploy Infrastructure TestInstance"
                }
            }
        }
    }
}