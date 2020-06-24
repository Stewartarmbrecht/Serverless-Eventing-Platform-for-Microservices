$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

#since we match the srs/tests organization this works
$here = $here -replace 'tests', 'Eden'

. "$here\$sut"    

# Import our module to use InModuleScope
Import-Module (Resolve-Path ".\Eden\Eden.psm1") -Force

InModuleScope "Eden" {
    Describe "Public/Build-EdenServiceApp" {
        Context "When executed only once" {
            It "Executes successfully for a build without error" {
                Mock Invoke-CommandBuild { 
                    Write-Verbose "Build ran successfully." 
                }
                {
                    Build-EdenServiceApp -Verbose
                } | Should -Not -Throw
            }
            It "Throws an error for a failed build" {
                Mock Invoke-CommandBuild { 
                    Write-Host "Build failed."
                    throw "Building the solution exited with an error."
                }
                {
                    Build-EdenServiceApp -Verbose 
                } | Should -Throw
            }
        }
        Context "Continuously" {
            It "Executes successfully" {
                Mock Invoke-CommandBuildContinuous { 
                    Write-Verbose "Build ran successfully." 
                }
                {
                    Build-EdenServiceApp -Continuous -Verbose
                } | Should -Not -Throw
            }
            It "Throws an error if the project is missing" {
                Mock Invoke-CommandBuildContinuous { 
                    Write-Host "Cannot find the project."
                    throw "Building the solution exited with an error."
                }
                {
                    Build-EdenServiceApp -Continuous -Verbose
                } | Should -Throw
            }
        }
    }
}