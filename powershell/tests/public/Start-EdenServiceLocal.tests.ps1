$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

#since we match the srs/tests organization this works
$here = $here -replace 'tests', 'Eden'

. "$here\$sut"    

# Import our module to use InModuleScope
Import-Module (Join-Path $PSScriptRoot "../../Eden/Eden.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "../TestUtilities.psm1") -Force

InModuleScope "Eden" {
    Describe "Public/Start-EdenServiceLocal" {
        BeforeEach {
            Mock Get-SolutionName { "TestSolution" }
            Mock Get-ServiceName { "TestService" }
            Set-TestEnvironment
            [System.Collections.ArrayList]$log = @()
            Mock Write-BuildInfo (Get-BuildInfoErrorBlock $log)
            Mock Write-BuildError (Get-BuildInfoErrorBlock $log)
        }
        Context "When executed successfully" {
            It "Prints the following logs" {
                Mock Start-EdenCommand (Get-StartEdenCommandBlock $log)
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlock $log) -ParameterFilter {
                    $EdenCommand -ne "Get-LocalServiceHealth"
                }
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlock $log -ReturnValueSet @($false,$true)) -ParameterFilter {
                    $EdenCommand -eq "Get-LocalServiceHealth"
                }
                Start-EdenServiceLocal -Verbose
                Assert-Logs $log @(
                    "TestSolution TestService Run TestEnvironment Starting the local service job.",
                    "Mock: Start-LocalService job starting. TestSolution TestService Run TestEnvironment",
                    "TestSolution TestService Run TestEnvironment Starting the public tunnel job.",
                    "Mock: Start-LocalTunnel job starting. TestSolution TestService Run TestEnvironment",
                    "TestSolution TestService Run TestEnvironment Checking whether the local service is ready.",
                    "TestSolution TestService Run TestEnvironment Get-LocalServiceHealth TestSolution TestService",
                    "TestSolution TestService Run TestEnvironment The local service failed the health check.",
                    "TestSolution TestService Run TestEnvironment Checking whether the local service is ready.",
                    "TestSolution TestService Run TestEnvironment Get-LocalServiceHealth TestSolution TestService",
                    "TestSolution TestService Run TestEnvironment The local service passed the health check.",
                    "TestSolution TestService Run TestEnvironment Deploying the event subscrpitions for the local service.",
                    "TestSolution TestService Run TestEnvironment Deploy-LocalSubscriptions TestSolution TestService",
                    "TestSolution TestService Run TestEnvironment Finished deploying the event subscrpitions for the local service."
                )
            }
        }
        Context "When executed continuously successfully" {
            It "Prints the following logs" {
                Mock Start-EdenCommand (Get-StartEdenCommandBlock $log)
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlock $log) -ParameterFilter {
                    $EdenCommand -ne "Get-LocalServiceHealth"
                }
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlock $log -ReturnValueSet @($false,$true)) -ParameterFilter {
                    $EdenCommand -eq "Get-LocalServiceHealth"
                }
                Start-EdenServiceLocal -Continuous -Verbose
                Assert-Logs $log @(
                    "!SKIP!",
                    "Mock: Start-LocalServiceContinuous job starting. TestSolution TestService Run TestEnvironment"
                    # Remaining logs ignored.
                )
            }
        }
        Context "When executed with start error" {
            It "Prints the following logs" {
                Mock Start-EdenCommand (Get-StartEdenCommandBlockWithError $log)
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlock $log) -ParameterFilter {
                    $EdenCommand -ne "Get-LocalServiceHealth"
                }
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlock $log -ReturnValueSet @($false,$true)) -ParameterFilter {
                    $EdenCommand -eq "Get-LocalServiceHealth"
                }
                { Start-EdenServiceLocal -Verbose } | Should -Throw
                Assert-Logs $log @(
                    "TestSolution TestService Run TestEnvironment Starting the local service job.",
                    "Mock: Start-LocalService job starting. TestSolution TestService Run TestEnvironment",
                    "TestSolution TestService Run TestEnvironment Starting the public tunnel job.",
                    "Mock: Start-LocalTunnel job starting. TestSolution TestService Run TestEnvironment",
                    "TestSolution TestService Run TestEnvironment Checking whether the local service is ready.",
                    "TestSolution TestService Run TestEnvironment Get-LocalServiceHealth TestSolution TestService",
                    "TestSolution TestService Run TestEnvironment The local service failed the health check.",
                    #TODO: Figure out how to get the actual thown message instead of "'"
                    "TestSolution TestService Run TestEnvironment Stopping and removing jobs due to exception. Message: 'Local service failed to run. Status Message: '''",
                    "TestSolution TestService Run TestEnvironment Stopped."
                )
            }
        }
        Context "When executed with tunnel error" {
            It "Prints the following logs" {
                Mock Start-EdenCommand (Get-StartEdenCommandBlockWithError $log) -ParameterFilter {
                    $EdenCommand -eq "Start-LocalTunnel"
                }
                Mock Start-EdenCommand (Get-StartEdenCommandBlock $log) -ParameterFilter {
                    $EdenCommand -ne "Start-LocalTunnel"
                }
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlock $log) -ParameterFilter {
                    $EdenCommand -ne "Get-LocalServiceHealth"
                }
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlock $log -ReturnValueSet @($false,$true)) -ParameterFilter {
                    $EdenCommand -eq "Get-LocalServiceHealth"
                }
                { Start-EdenServiceLocal -Verbose } | Should -Throw
                Assert-Logs $log @(
                    "TestSolution TestService Run TestEnvironment Starting the local service job.",
                    "Mock: Start-LocalService job starting. TestSolution TestService Run TestEnvironment",
                    "TestSolution TestService Run TestEnvironment Starting the public tunnel job.",
                    "Mock: Start-LocalTunnel job starting. TestSolution TestService Run TestEnvironment",
                    "TestSolution TestService Run TestEnvironment Checking whether the local service is ready.",
                    "TestSolution TestService Run TestEnvironment Get-LocalServiceHealth TestSolution TestService",
                    "TestSolution TestService Run TestEnvironment The local service failed the health check.",
                    "TestSolution TestService Run TestEnvironment Stopping and removing jobs due to exception. Message: 'Local tunnel failed to run. Status Message: '''",
                    "TestSolution TestService Run TestEnvironment Stopped."
                )
            }
        }
        Context "When executed with feature testing" {
            It "Prints the following logs" {
                Mock Start-EdenCommand (Get-StartEdenCommandBlock $log)
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlock $log) -ParameterFilter {
                    $EdenCommand -ne "Get-LocalServiceHealth"
                }
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlock $log -ReturnValueSet @($false,$true)) -ParameterFilter {
                    $EdenCommand -eq "Get-LocalServiceHealth"
                }
                Start-EdenServiceLocal -RunFeatureTests -Verbose
                Assert-Logs $log @(
                    "TestSolution TestService Run TestEnvironment Starting the local service job.",
                    "Mock: Start-LocalService job starting. TestSolution TestService Run TestEnvironment",
                    "TestSolution TestService Run TestEnvironment Starting the public tunnel job.",
                    "Mock: Start-LocalTunnel job starting. TestSolution TestService Run TestEnvironment",
                    "TestSolution TestService Run TestEnvironment Checking whether the local service is ready.",
                    "TestSolution TestService Run TestEnvironment Get-LocalServiceHealth TestSolution TestService",
                    "TestSolution TestService Run TestEnvironment The local service failed the health check.",
                    "TestSolution TestService Run TestEnvironment Checking whether the local service is ready.",
                    "TestSolution TestService Run TestEnvironment Get-LocalServiceHealth TestSolution TestService",
                    "TestSolution TestService Run TestEnvironment The local service passed the health check.",
                    "TestSolution TestService Run TestEnvironment Deploying the event subscrpitions for the local service.",
                    "TestSolution TestService Run TestEnvironment Deploy-LocalSubscriptions TestSolution TestService",
                    "TestSolution TestService Run TestEnvironment Finished deploying the event subscrpitions for the local service.",
                    "TestSolution TestService Run TestEnvironment Testing the service features.",
                    "TestSolution TestService Run TestEnvironment Test-Features TestSolution TestService",
                    "TestSolution TestService Run TestEnvironment Finished testing the service features.",
                    "TestSolution TestService Run TestEnvironment Stopping and removing jobs."
                )
            }
        }
        Context "When executed with feature testing continuously" {
            It "Prints the following logs" {
                Mock Start-EdenCommand (Get-StartEdenCommandBlock $log)
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlock $log) -ParameterFilter {
                    $EdenCommand -ne "Get-LocalServiceHealth"
                }
                Mock Invoke-EdenCommand (Get-InvokeEdenCommandBlock $log -ReturnValueSet @($false,$true)) -ParameterFilter {
                    $EdenCommand -eq "Get-LocalServiceHealth"
                }
                Start-EdenServiceLocal -RunFeatureTestsContinuously -Verbose
                Assert-Logs $log @(
                    "TestSolution TestService Run TestEnvironment Starting the local service job.",
                    "Mock: Start-LocalService job starting. TestSolution TestService Run TestEnvironment",
                    "TestSolution TestService Run TestEnvironment Starting the public tunnel job.",
                    "Mock: Start-LocalTunnel job starting. TestSolution TestService Run TestEnvironment",
                    "TestSolution TestService Run TestEnvironment Checking whether the local service is ready.",
                    "TestSolution TestService Run TestEnvironment Get-LocalServiceHealth TestSolution TestService",
                    "TestSolution TestService Run TestEnvironment The local service failed the health check.",
                    "TestSolution TestService Run TestEnvironment Checking whether the local service is ready.",
                    "TestSolution TestService Run TestEnvironment Get-LocalServiceHealth TestSolution TestService",
                    "TestSolution TestService Run TestEnvironment The local service passed the health check.",
                    "TestSolution TestService Run TestEnvironment Deploying the event subscrpitions for the local service.",
                    "TestSolution TestService Run TestEnvironment Deploy-LocalSubscriptions TestSolution TestService",
                    "TestSolution TestService Run TestEnvironment Finished deploying the event subscrpitions for the local service.",
                    "TestSolution TestService Run TestEnvironment Testing the service features continuously.",
                    "Mock: Test-FeaturesContinuously job starting. TestSolution TestService Run TestEnvironment"
                )
            }
        }
    }
}