Set-Location ../../
./DevAudio.ps1
Set-Location $PSScriptRoot
Start-EdenServiceLocal -Verbose

# Import-Module ../../PowerShell/Eden/Eden.psm1 -Force
# . ../../PowerShell/Eden/Private/Start-EdenCommand.ps1 
# $job = Start-EdenCommand "Start-LocalTunnel" $(Get-EdenEnvConfig) "My Test" -Verbose
# Get-Job | Out-String | Write-Host
# Get-Job | Receive-Job | Out-String | Write-Host
# return $job

