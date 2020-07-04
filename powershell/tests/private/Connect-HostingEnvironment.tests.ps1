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
    Describe "Private/Connect-HostingEnvironment" {
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
                    param($EdenEnvConfig)
                    $logEntry = "Invoke-CommandConnect $($EdenEnvConfig.ServicePrincipalId) $($EdenEnvConfig.ServicePrincipalPassword.Length -gt 0) $($EdenEnvConfig.TenantId)"
                    Write-Verbose $logEntry
                    $log.Add($logEntry)
                }
                Connect-HostingEnvironment -LoggingPrefix "TestLoggingPrefix"
            }
            It "Prints a message it is connecting to the hosting environment." {
                $log[0] | Should -Be "TestLoggingPrefix Connecting to the 'TestEnvironment' environment in the 'TestTenantId' tenant as 'TestServicePrincipalId'"
            }
            It "Invokes the command to connect to the hosting environment." {
                $log[1] | Should -Be "Invoke-CommandConnect TestServicePrincipalId True TestTenantId"
            }
        }
        Context "When executed with exception" {
            BeforeAll {
                [System.Collections.ArrayList]$log = @()
                Mock Write-BuildInfo {
                    param($Message, $LoggingPrefix)
                    $logEntry = "$LoggingPrefix $Message"
                    Write-Verbose $logEntry
                    $log.Add($logEntry)
                }
                Mock Write-BuildError {
                    param($Message, $LoggingPrefix)
                    $logEntry = "Error $LoggingPrefix $Message"
                    Write-Verbose $logEntry
                    $log.Add($logEntry)
                }
                Mock Invoke-CommandConnect {
                    param($EdenEnvConfig)
                    $logEntry = "Invoke-CommandConnect $($EdenEnvConfig.ServicePrincipalId) $($EdenEnvConfig.ServicePrincipalPassword.Length -gt 0) $($EdenEnvConfig.TenantId)"
                    Write-Verbose $logEntry
                    $log.Add($logEntry)
                    throw "My Error!"
                }
                {
                    Connect-HostingEnvironment -LoggingPrefix "TestLoggingPrefix"
                } | Should -Throw
            }
            It "Prints a message it is connecting to the hosting environment." {
                $log[0] | Should -Be "TestLoggingPrefix Connecting to the 'TestEnvironment' environment in the 'TestTenantId' tenant as 'TestServicePrincipalId'"
            }
            It "Invokes the command to connect to the hosting environment." {
                $log[1] | Should -Be "Invoke-CommandConnect TestServicePrincipalId True TestTenantId"
            }
            It "Prints a message it experienced an error." {
                $log[2] | Should -Be "Error TestLoggingPrefix Experienced an error connecting to the hosting environment."
                $log[3] | Should -Be "Error TestLoggingPrefix Error message: 'My Error!'"
            }
        }
    }
}