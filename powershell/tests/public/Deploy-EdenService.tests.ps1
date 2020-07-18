$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

#since we match the srs/tests organization this works
$here = $here -replace 'tests', 'Eden'

. "$here\$sut"    

# Import our module to use InModuleScope
Import-Module (Join-Path $PSScriptRoot "../../Eden/Eden.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "../TestUtilities.psm1") -Force

InModuleScope "Eden" {
    Describe "Public/Test-EdenServiceFeatures" {
        Context "When executed" {
            It "Calls the commands to deploy infrastructure, application, and subscriptions" {
                [System.Collections.ArrayList]$log = @()
                Mock Deploy-EdenServiceInfrastructure {
                    [Void]$log.Add("Infra")
                }
                Mock Deploy-EdenServiceApplication {
                    [Void]$log.Add("App")
                }
                Mock Deploy-EdenServiceSubscriptions {
                    [Void]$log.Add("Sub")
                }
                Deploy-EdenService
                $log[0] | Should -Be "Infra"
                $log[1] | Should -Be "App"
                $log[2] | Should -Be "Sub"
            }
        }
    }
}