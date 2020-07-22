$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

#since we match the srs/tests organization this works
$here = $here -replace 'tests', 'Eden'

. "$here\$sut"    

# Import our module to use InModuleScope
Import-Module (Join-Path $PSScriptRoot "../../Eden/Eden.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "../TestUtilities.psm1") -Force

InModuleScope "Eden" {
    Describe "Public/Invoke-EdenServicePipeline" {
        Context "When executed" {
            It "Calls the commands to build, unit test, feature test, publish, and deploy the service" {
                [System.Collections.ArrayList]$log = @()
                Mock Build-EdenService {
                    [Void]$log.Add("Build")
                }
                Mock Test-EdenServiceCode {
                    [Void]$log.Add("UnitTest")
                }
                Mock Test-EdenServiceFeatures {
                    [Void]$log.Add("FeatureTest")
                }
                Mock Publish-EdenService {
                    [Void]$log.Add("Publish")
                }
                Mock Deploy-EdenService {
                    [Void]$log.Add("Deploy")
                }
                Invoke-EdenServicePipeline
                $log[0] | Should -Be "Build"
                $log[1] | Should -Be "UnitTest"
                $log[2] | Should -Be "FeatureTest"
                $log[3] | Should -Be "Publish"
                $log[4] | Should -Be "Deploy"
            }
        }
    }
}