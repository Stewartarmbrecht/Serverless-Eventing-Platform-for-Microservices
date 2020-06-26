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
    Describe "Public/Start-EdenServiceLocal" {
        BeforeAll {
            Mock Get-SolutionName { "TestSolution" }
            Mock Get-ServiceName { "TestService" }
            Set-TestEnvironment
        }
        Context "When executed with successful health status" {
            BeforeEach {
                Get-Job | Stop-Job
                Get-Job | Remove-Job

                $startAppJob = Start-ThreadJob -Name "rt-ServiceTest" -ScriptBlock {
                    Write-Verbose "I was hit!"
                    Start-Sleep -Milliseconds 100
                } -ArgumentList $ArgumentList

                Mock Get-HealthStatus { $TRUE }
                Mock Start-ApplicationJob { 
                    # param($Location, $Port, $LoggingPrefix)
                    # Write-Verbose "Location: $Location"
                    # Write-Verbose "Port: $Port"
                    # Write-Verbose "LoggingPrefix: $LoggingPrefix"
                    return $startAppJob
                }
                Mock Write-BuildInfo {}
                Start-EdenServiceLocal
                $startAppJob | Wait-Job
                $startAppJob | Remove-Job
            }
            It "Should call the Start-ApplicationJob function" {
                Assert-MockCalled Start-ApplicationJob 1 -ParameterFilter {
                    $Location -eq "./Service" `
                    -and `
                    $Port -eq 9876 `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
            It "Should Call the Get-HealthStatus" {
                Assert-MockCalled Get-HealthStatus 1 -ParameterFilter {
                    $PublicUrl -eq "http://localhost:9876" `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
            It "Should print the message for starting the jobs." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Starting jobs." -and $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
            It "Should print the message for all jobs stopped." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "All jobs stopped running." -and $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
        }
        Context "When executed with successful health status and run automated tests" {
            BeforeEach {
                Get-Job | Stop-Job
                Get-Job | Remove-Job

                $startAppJob = Start-ThreadJob -Name "rt-ServiceTest" -ScriptBlock {
                    #Write-Verbose "I was hit!"
                    Start-Sleep -Milliseconds 500
                } -ArgumentList $ArgumentList

                $automatedTestJob = Start-ThreadJob -Name "rt-AutomatedTest" -ScriptBlock {
                    Write-Verbose "I was hit!"
                    Start-Sleep -Milliseconds 500
                } -ArgumentList $ArgumentList

                Mock Get-HealthStatus { 
                    param($PublicUrl, $LoggingPrefix)
                    Write-Verbose "$LoggingPrefix $PublicUrl"
                    $TRUE 
                }
                Mock Start-ApplicationJob { 
                    # param($Location, $Port, $LoggingPrefix)
                    # Write-Verbose "Location: $Location"
                    # Write-Verbose "Port: $Port"
                    # Write-Verbose "LoggingPrefix: $LoggingPrefix"
                    return $startAppJob
                }
                Mock Test-AutomatedJob { 
                    param($SolutionName, $ServiceName, $AutomatedUrl, $LoggingPrefix)
                    Write-Verbose "Solution Name: $SolutionName"
                    Write-Verbose "Service Name: $ServiceName"
                    Write-Verbose "AutomatedUrl: $AutomatedUrl"
                    Write-Verbose "LoggingPrefix: $LoggingPrefix"
                    return $automatedTestJob
                }
                Mock Write-BuildInfo {
                    param($Message, $LoggingPrefix)
                    Write-Verbose "$LoggingPrefix $Message"
                }
                Start-EdenServiceLocal -RunAutomatedTests
                Get-Job | Stop-Job
                Get-Job | Remove-Job
            }
            It "Should call the Start-ApplicationJob function" {
                Assert-MockCalled Start-ApplicationJob 1 -ParameterFilter {
                    $Location -eq "./Service" `
                    -and `
                    $Port -eq 9876 `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
            It "Should Call the Get-HealthStatus" {
                Assert-MockCalled Get-HealthStatus 1 -ParameterFilter {
                    $PublicUrl -eq "http://localhost:9876" `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
            It "Should print the message for starting the jobs." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Starting jobs." -and $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
            It "Should print the message for all jobs stopped." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "All jobs stopped running." -and $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
            It "Should call the Start-ApplicationJob function" {
                Assert-MockCalled Test-AutomatedJob 1 -ParameterFilter {
                    $SolutionName -eq "TestSolution" `
                    -and `
                    $ServiceName -eq "TestService" `
                    -and `
                    $AutomatedUrl -eq "http://localhost:9876/api" `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
            It "Should print the message for all jobs stopped." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "All jobs stopped running." -and $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
            It "Should print the message for starting the jobs." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Starting automated test job." -and $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
        }
        Context "When executed with successful health status and run automated tests continuously" {
            BeforeEach {
                Get-Job | Stop-Job
                Get-Job | Remove-Job

                $startAppJob = Start-ThreadJob -Name "rt-ServiceTest" -ScriptBlock {
                    #Write-Verbose "I was hit!"
                    Start-Sleep -Milliseconds 500
                } -ArgumentList $ArgumentList

                $automatedTestJob = Start-ThreadJob -Name "rt-AutomatedTest" -ScriptBlock {
                    Write-Verbose "I was hit!"
                    Start-Sleep -Milliseconds 500
                } -ArgumentList $ArgumentList

                Mock Get-HealthStatus { 
                    param($PublicUrl, $LoggingPrefix)
                    Write-Verbose "$LoggingPrefix $PublicUrl"
                    $TRUE 
                }
                Mock Start-ApplicationJob { 
                    # param($Location, $Port, $LoggingPrefix)
                    # Write-Verbose "Location: $Location"
                    # Write-Verbose "Port: $Port"
                    # Write-Verbose "LoggingPrefix: $LoggingPrefix"
                    return $startAppJob
                }
                Mock Test-AutomatedJob { 
                    param($SolutionName, $ServiceName, $AutomatedUrl, $LoggingPrefix)
                    Write-Verbose "Solution Name: $SolutionName"
                    Write-Verbose "Service Name: $ServiceName"
                    Write-Verbose "AutomatedUrl: $AutomatedUrl"
                    Write-Verbose "LoggingPrefix: $LoggingPrefix"
                    return $automatedTestJob
                }
                Mock Write-BuildInfo {
                    param($Message, $LoggingPrefix)
                    Write-Verbose "$LoggingPrefix $Message"
                }
                Start-EdenServiceLocal -RunAutomatedTestsContinuously
                Get-Job | Stop-Job
                Get-Job | Remove-Job
            }
            It "Should call the Start-ApplicationJob function" {
                Assert-MockCalled Start-ApplicationJob 1 -ParameterFilter {
                    $Location -eq "./Service" `
                    -and `
                    $Port -eq 9876 `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
            It "Should Call the Get-HealthStatus" {
                Assert-MockCalled Get-HealthStatus 1 -ParameterFilter {
                    $PublicUrl -eq "http://localhost:9876" `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
            It "Should print the message for starting the jobs." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Starting jobs." -and $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
            It "Should print the message for all jobs stopped." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "All jobs stopped running." -and $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
            It "Should call the Test-AutomatedJob function continuously" {
                Assert-MockCalled Test-AutomatedJob 1 -ParameterFilter {
                    $SolutionName -eq "TestSolution" `
                    -and `
                    $ServiceName -eq "TestService" `
                    -and `
                    $AutomatedUrl -eq "http://localhost:9876/api" `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Run TestInstance" `
                    -and `
                    $Continuous -eq $true
                }
            }
            It "Should print the message for all jobs stopped." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "All jobs stopped running." -and $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
            It "Should print the message for starting the jobs." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Starting continuous automated test job." -and $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
        }
        Context "When executed with successful health status and run automated tests failed" {
            BeforeEach {
                Get-Job | Stop-Job
                Get-Job | Remove-Job

                $startAppJob = Start-ThreadJob -Name "rt-ServiceTest" -ScriptBlock {
                    Start-Sleep -Milliseconds 500
                } -ArgumentList $ArgumentList

                $automatedTestJob = Start-ThreadJob -Name "rt-AutomatedTest" -ScriptBlock {
                    Start-Sleep -Milliseconds 500
                    throw
                } -ArgumentList $ArgumentList

                Mock Get-HealthStatus { 
                    param($PublicUrl, $LoggingPrefix)
                    # Write-Verbose "$LoggingPrefix $PublicUrl"
                    $TRUE 
                }
                Mock Start-ApplicationJob { 
                    # param($Location, $Port, $LoggingPrefix)
                    # Write-Verbose "Location: $Location"
                    # Write-Verbose "Port: $Port"
                    # Write-Verbose "LoggingPrefix: $LoggingPrefix"
                    return $startAppJob
                }
                Mock Test-AutomatedJob { 
                    param($SolutionName, $ServiceName, $AutomatedUrl, $LoggingPrefix)
                    # Write-Verbose "Solution Name: $SolutionName"
                    # Write-Verbose "Service Name: $ServiceName"
                    # Write-Verbose "AutomatedUrl: $AutomatedUrl"
                    # Write-Verbose "LoggingPrefix: $LoggingPrefix"
                    return $automatedTestJob
                }
                Mock Write-BuildInfo {
                    param($Message, $LoggingPrefix)
                    Write-Verbose "$LoggingPrefix $Message"
                }
                Mock Write-BuildError {
                    param($Message, $LoggingPrefix)
                    Write-Verbose "$LoggingPrefix $Message"
                }
                {
                    Start-EdenServiceLocal -RunAutomatedTests
                } | Should -Throw
                Get-Job | Stop-Job
                Get-Job | Remove-Job
            }
            It "Should call the Start-ApplicationJob function" {
                Assert-MockCalled Start-ApplicationJob 1 -ParameterFilter {
                    $Location -eq "./Service" `
                    -and `
                    $Port -eq 9876 `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
            It "Should Call the Get-HealthStatus" {
                Assert-MockCalled Get-HealthStatus 1 -ParameterFilter {
                    $PublicUrl -eq "http://localhost:9876" `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
            It "Should print the message for starting the jobs." {
                Assert-MockCalled Write-BuildInfo 1 -ParameterFilter {
                    $Message -eq "Starting jobs." -and $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
            It "Should call the Test-AutomatedJob function continuously" {
                Assert-MockCalled Test-AutomatedJob 1 -ParameterFilter {
                    $SolutionName -eq "TestSolution" `
                    -and `
                    $ServiceName -eq "TestService" `
                    -and `
                    $AutomatedUrl -eq "http://localhost:9876/api" `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Run TestInstance" 
                }
            }
            It "Should print the message for an exception." {
                Assert-MockCalled Write-BuildError 1 -ParameterFilter {
                    $Message -eq "Stopping and removing jobs due to exception. Message: 'One of the jobs failed.'" `
                    -and `
                    $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
            It "Should print the message for jobs stopped." {
                Assert-MockCalled Write-BuildError 1 -ParameterFilter {
                    $Message -eq "Stopped." -and $LoggingPrefix -eq "TestSolution TestService Run TestInstance"
                }
            }
        }
    }
}