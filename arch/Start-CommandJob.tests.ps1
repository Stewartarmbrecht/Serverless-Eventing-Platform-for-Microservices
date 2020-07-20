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
    Describe "Private/Start-ApplicationJob" {
        BeforeEach {
            Mock Get-SolutionName { "TestSolution" }
            Mock Get-ServiceName { "TestService" }
            $edenEnvConfig = Set-TestEnvironment
            [System.Collections.ArrayList]$log = @()
            Mock Write-EdenBuildInfo (Get-BuildInfoErrorBlock $log)
            Mock Write-EdenBuildError (Get-BuildInfoErrorBlock $log)
        }
        Context "When executed with success" {
            BeforeEach {
                $command = {
                    param([EdenEnvConfig]$EdenEnvConfig)
                    Write-EdenBuildInfo "Test command." "TestPrefix" 
                }

                Mock Start-ThreadJob { 
                    param ([String]$Name, [ScriptBlock]$ScriptBlock, $ArgumentList) 
                    Invoke-Command $ScriptBlock -ArgumentList $ArgumentList
                }

                Start-CommandJob `
                    -Command $command `
                    -EdenEnvConfig $edenEnvConfig `
                    -LoggingPrefix "TestLogPrefix"
            }
            It "Print the following logs" {
                Assert-Logs $log @(
                    "TestLogPrefix Starting job for command: 'Invoke-CommandBuild'",
                    "TestPrefix Invoke-CommandBuild"
                )
            }
        }
    }
}