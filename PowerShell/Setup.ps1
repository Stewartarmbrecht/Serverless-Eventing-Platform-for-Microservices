Install-Module -Name InvokeBuild -Force -Verbose
Invoke-Build -Task InstallDependencies -Verbose
Invoke-Build -Task Test -Verbose
