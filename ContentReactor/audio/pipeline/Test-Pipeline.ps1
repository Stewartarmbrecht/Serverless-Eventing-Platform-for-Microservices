Set-Location ./ContentReactor/audio/pipeline

function MyTest {
	[CmdletBinding()]
	param()

	$VerbosePreference

	Write-Verbose "I Was hit."
}
MyTest -Verbose
MyTest


./Build.ps1
./Build.ps1 -Verbose
./Test-Unit.ps1
./Test-Unit.ps1 -Verbose
./Start-Service.ps1 `
	-InstanceName $Env:InstanceName  `
	-UserName $Env:UserName `
	-Password $Env:Password `
	-TenantId $Env:TenantId `
	-UniqueDeveloperId $Env:UniqueDeveloperId `
	-Verbose

./Test-EndToEnd.ps1 `
	-InstanceName $Env:InstanceName  `
	-UserName $Env:UserName `
	-Password $Env:Password `
	-TenantId $Env:TenantId `
	-UniqueDeveloperId $Env:UniqueDeveloperId `
	-Verbose


$Test = ""
if(![String]::IsNullOrEmpty($Test)) {
	Write-Host "Hit."
}
