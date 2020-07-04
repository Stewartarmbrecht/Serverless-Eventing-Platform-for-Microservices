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
    Describe "Public/Get-EdenEnvConfig" {
        Context "When called when all variables are set" {
            It "Gets all variables." {
                $pswd = ConvertTo-SecureString "TestServicePrincipalPassword" -AsPlainText
                Set-EdenEnvConfig `
                    -SolutionName "TestSolution" `
                    -ServiceName "TestService" `
                    -EnvironmentName "TestEnvironment" `
                    -TenantId "TestTenantId" `
                    -ServicePrincipalId "TestServicePrincipalId" `
                    -ServicePrincipalPassword $pswd `
                    -DeveloperId "TestDeveloperId" `
                    -Region "TestRegion"

                $envConfig = Get-EdenEnvConfig `
                    -SolutionName "TestSolution" `
                    -ServiceName "TestService"

                $envConfig.EnvironmentName | Should -Be "TestEnvironment"
                $envConfig.Region | Should -Be "TestRegion"
                $envConfig.ServicePrincipalId | Should -Be "TestServicePrincipalId"
                ConvertFrom-SecureString $envConfig.ServicePrincipalPassword -AsPlainText | Should -Be "TestServicePrincipalPassword"
                $envConfig.TenantId | Should -Be "TestTenantId"
                $envConfig.DeveloperId | Should -Be "TestDeveloperId"
            }
        }
        Context "When called when the settings are cleared" {
            It "Returns null values." {
                Set-EdenEnvConfig -Clear -SolutionName "TestSolution" -ServiceName "TestService"

                $envConfig = Get-EdenEnvConfig `
                    -SolutionName "TestSolution" `
                    -ServiceName "TestService"

                $envConfig.EnvironmentName | Should -Be ""
                $envConfig.Region | Should -Be ""
                $envConfig.ServicePrincipalId | Should -Be ""
                $envConfig.ServicePrincipalPassword | Should -Be $null
                $envConfig.TenantId | Should -Be ""
                $envConfig.DeveloperId | Should -Be ""
            }
        }
        Context "When called and the settings are cleared and the prompt switch is passed" {
            It "Should call the Set-EdenEnvConfig to prompt for the missing values." {
                Set-EdenEnvConfig -Clear -SolutionName "TestSolution" -ServiceName "TestService"

                Mock Read-Host { return "MyTest" } -ParameterFilter { $AsSecureString -eq $false -and $Prompt -notlike "*port*" }
                Mock Read-Host { return ConvertTo-SecureString "MyTest" -AsPlainText } -ParameterFilter { $AsSecureString -eq $true }

                $envConfig = Get-EdenEnvConfig `
                    -SolutionName "TestSolution" `
                    -ServiceName "TestService" `
                    -Prompt

                $envConfig.EnvironmentName | Should -Be "MyTest"
                $envConfig.Region | Should -Be "MyTest"
                $envConfig.ServicePrincipalId | Should -Be "MyTest"
                (ConvertFrom-SecureString $envConfig.ServicePrincipalPassword -AsPlainText) | Should -Be "MyTest"
                $envConfig.TenantId | Should -Be "MyTest"
                $envConfig.DeveloperId | Should -Be "MyTest"
            }
        }
        Context "When called and the settings are cleared and the check switch is passed" {
            It "Should throw an exception listing the configurations that are missing." {
                Set-EdenEnvConfig -Clear -SolutionName "TestSolution" -ServiceName "TestService"

                try {
                    Get-EdenEnvConfig `
                        -SolutionName "TestSolution" `
                        -ServiceName "TestService" `
                        -Check -Verbose
                    
                    throw "Did not thow an exception."
                }
                catch {
                    $_.Exception.Message | Should -Be "The following Eden environment configuration values are missing: DeveloperId, EnvironmentName, Region, ServicePrincipalId, ServicePrincipalPassword, TenantId"
                }
            }
        }
        Context "When called and some of the settings are cleared and the check switch is passed" {
            It "Should throw an exception listing the configurations that are missing." {
                Mock Read-Host { return $null }
    
                $pswd = ConvertTo-SecureString "TestServicePrincipalPassword" -AsPlainText
                Set-EdenEnvConfig `
                    -SolutionName "TestSolution" `
                    -ServiceName "TestService" `
                    -EnvironmentName "TestEnvironment" `
                    -ServicePrincipalId "TestServicePrincipalId" `
                    -ServicePrincipalPassword $pswd `
                    -DeveloperId "TestDeveloperId" `
                    -Region "TestRegion"

                try {
                    Get-EdenEnvConfig `
                        -SolutionName "TestSolution" `
                        -ServiceName "TestService" `
                        -Check -Verbose
                    
                    throw "Did not thow an exception."
                }
                catch {
                    $_.Exception.Message | Should -Be "The following Eden environment configuration values are missing: TenantId"
                }
            }
        }
        Context "When called when all variables are set and the check switch is passed" {
            It "Gets all variables." {
                $pswd = ConvertTo-SecureString "TestServicePrincipalPassword" -AsPlainText
                Set-EdenEnvConfig `
                    -SolutionName "TestSolution" `
                    -ServiceName "TestService" `
                    -EnvironmentName "TestEnvironment" `
                    -TenantId "TestTenantId" `
                    -ServicePrincipalId "TestServicePrincipalId" `
                    -ServicePrincipalPassword $pswd `
                    -DeveloperId "TestDeveloperId" `
                    -Region "TestRegion"

                $envConfig = Get-EdenEnvConfig `
                    -SolutionName "TestSolution" `
                    -ServiceName "TestService" `
                    -Check

                $envConfig.EnvironmentName | Should -Be "TestEnvironment"
                $envConfig.Region | Should -Be "TestRegion"
                $envConfig.ServicePrincipalId | Should -Be "TestServicePrincipalId"
                ConvertFrom-SecureString $envConfig.ServicePrincipalPassword -AsPlainText | Should -Be "TestServicePrincipalPassword"
                $envConfig.TenantId | Should -Be "TestTenantId"
                $envConfig.DeveloperId | Should -Be "TestDeveloperId"
            }
        }
    }
}