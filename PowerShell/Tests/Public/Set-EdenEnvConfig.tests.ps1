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
    Describe "Public/Set-EdenEnvConfig" {
        Context "When called to set all variables" {
            It "Sets all variables." {
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

                [System.Environment]::GetEnvironmentVariable('TestSolution.TestService.EnvironmentName') | Should -Be "TestEnvironment"
                [System.Environment]::GetEnvironmentVariable('TestSolution.TestService.Region') | Should -Be "TestRegion"
                [System.Environment]::GetEnvironmentVariable('TestSolution.TestService.ServicePrincipalId') | Should -Be "TestServicePrincipalId"
                $securePassword = ConvertTo-SecureString ([System.Environment]::GetEnvironmentVariable('TestSolution.TestService.ServicePrincipalPassword'))
                ConvertFrom-SecureString $securePassword -AsPlainText | Should -Be "TestServicePrincipalPassword"
                [System.Environment]::GetEnvironmentVariable('TestSolution.TestService.TenantId') | Should -Be "TestTenantId"
                [System.Environment]::GetEnvironmentVariable('TestSolution.TestService.DeveloperId') | Should -Be "TestDeveloperId"
            }
        }
        Context "When called to clear all variables" {
            It "Clears all variables." {
                Set-EdenEnvConfig -Clear -SolutionName "TestSolution" -ServiceName "TestService"

                [System.Environment]::GetEnvironmentVariable('TestSolution.TestService.EnvironmentName') | Should -Be $null
                [System.Environment]::GetEnvironmentVariable('TestSolution.TestService.Region') | Should -Be $null
                [System.Environment]::GetEnvironmentVariable('TestSolution.TestService.ServicePrincipalId') | Should -Be $null
                [System.Environment]::GetEnvironmentVariable('TestSolution.TestService.ServicePrincipalPassword') | Should -Be $null
                [System.Environment]::GetEnvironmentVariable('TestSolution.TestService.TenantId') | Should -Be $null
                [System.Environment]::GetEnvironmentVariable('TestSolution.TestService.DeveloperId') | Should -Be $null
                [System.Environment]::GetEnvironmentVariable('TestSolution.TestService.LocalHostingPort') | Should -Be $null
            }
        }
        Context "When called without passing in parameters" {
            It "Prompts for variables." {
                Set-EdenEnvConfig -Clear -SolutionName "TestSolution" -ServiceName "TestService"

                Mock Read-Host { return "MyTest" } -ParameterFilter { $AsSecureString -eq $false -and $Prompt -notlike "*port*" }
                Mock Read-Host { return ConvertTo-SecureString "MyTest" -AsPlainText } -ParameterFilter { $AsSecureString -eq $true }

                Set-EdenEnvConfig -SolutionName "TestSolution" -ServiceName "TestService"

                [System.Environment]::GetEnvironmentVariable('TestSolution.TestService.EnvironmentName') | Should -Be "MyTest"
                [System.Environment]::GetEnvironmentVariable('TestSolution.TestService.Region') | Should -Be "MyTest"
                [System.Environment]::GetEnvironmentVariable('TestSolution.TestService.ServicePrincipalId') | Should -Be "MyTest"
                $securePassword = ConvertTo-SecureString ([System.Environment]::GetEnvironmentVariable('TestSolution.TestService.ServicePrincipalPassword'))
                ConvertFrom-SecureString $securePassword -AsPlainText | Should -Be "MyTest"
                [System.Environment]::GetEnvironmentVariable('TestSolution.TestService.TenantId') | Should -Be "MyTest"
                [System.Environment]::GetEnvironmentVariable('TestSolution.TestService.DeveloperId') | Should -Be "MyTest"
            }
        }
    }
}