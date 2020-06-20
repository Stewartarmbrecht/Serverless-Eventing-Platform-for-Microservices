$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

#since we match the srs/tests organization this works
$here = $here -replace 'tests', 'Eden'

. "$here\$sut"    

# Import our module to use InModuleScope
Import-Module (Resolve-Path ".\Eden\Eden.psm1") -Force

InModuleScope "Eden" {
    Describe "Public/Set-EnvironmentVariables" {
        Context "When called to set all variables" {
            It "Sets all variables." {
                $pswd = ConvertTo-SecureString "TestPassword" -AsPlainText
                Set-EdenServiceEnvVariables `
                    -InstanceName "TestInstName" `
                    -Region "TestRegion" `
                    -UserId "TestUserId" `
                    -Password $pswd `
                    -TenantId "TestTenantId" `
                    -UniqueDeveloperId "TestUniqueDeveloperId" `
                    -LocalHostingPort 9999    

                [System.Environment]::GetEnvironmentVariable('Eden.powershell.InstanceName') | Should -Be "TestInstName"
                [System.Environment]::GetEnvironmentVariable('Eden.powershell.Region') | Should -Be "TestRegion"
                [System.Environment]::GetEnvironmentVariable('Eden.powershell.UserId') | Should -Be "TestUserId"
                $securePassword = ConvertTo-SecureString ([System.Environment]::GetEnvironmentVariable('Eden.powershell.Password'))
                ConvertFrom-SecureString $securePassword -AsPlainText | Should -Be "TestPassword"
                [System.Environment]::GetEnvironmentVariable('Eden.powershell.TenantId') | Should -Be "TestTenantId"
                [System.Environment]::GetEnvironmentVariable('Eden.powershell.UniqueDeveloperId') | Should -Be "TestUniqueDeveloperId"
                [System.Environment]::GetEnvironmentVariable('Eden.powershell.LocalHostingPort') | Should -Be 9999
            }
        }
        Context "When called to clear all variables" {
            It "Clears all variables." {
                Set-EdenServiceEnvVariables -Clear

                [System.Environment]::GetEnvironmentVariable('Eden.powershell.InstanceName') | Should -Be $null
                [System.Environment]::GetEnvironmentVariable('Eden.powershell.Region') | Should -Be $null
                [System.Environment]::GetEnvironmentVariable('Eden.powershell.UserId') | Should -Be $null
                [System.Environment]::GetEnvironmentVariable('Eden.powershell.Password') | Should -Be $null
                [System.Environment]::GetEnvironmentVariable('Eden.powershell.TenantId') | Should -Be $null
                [System.Environment]::GetEnvironmentVariable('Eden.powershell.UniqueDeveloperId') | Should -Be $null
                [System.Environment]::GetEnvironmentVariable('Eden.powershell.LocalHostingPort') | Should -Be $null
            }
        }
        Context "When called without passing in parameters" {
            It "Prompts for variables." {
                Set-EdenServiceEnvVariables -Clear

                Mock Read-Host { return "MyTest" } -ParameterFilter { $AsSecureString -eq $false -and $Prompt -notlike "*port*" }
                Mock Read-Host { return 9876 } -ParameterFilter { $Prompt -Like "*port*" }
                Mock Read-Host { return ConvertTo-SecureString "MyTest" -AsPlainText } -ParameterFilter { $AsSecureString -eq $true }

                Set-EdenServiceEnvVariables

                [System.Environment]::GetEnvironmentVariable('Eden.powershell.InstanceName') | Should -Be "MyTest"
                [System.Environment]::GetEnvironmentVariable('Eden.powershell.Region') | Should -Be "MyTest"
                [System.Environment]::GetEnvironmentVariable('Eden.powershell.UserId') | Should -Be "MyTest"
                $securePassword = ConvertTo-SecureString ([System.Environment]::GetEnvironmentVariable('Eden.powershell.Password'))
                ConvertFrom-SecureString $securePassword -AsPlainText | Should -Be "MyTest"
                [System.Environment]::GetEnvironmentVariable('Eden.powershell.TenantId') | Should -Be "MyTest"
                [System.Environment]::GetEnvironmentVariable('Eden.powershell.UniqueDeveloperId') | Should -Be "MyTest"
                [System.Environment]::GetEnvironmentVariable('Eden.powershell.LocalHostingPort') | Should -Be 9876
            }
        }
    }
}