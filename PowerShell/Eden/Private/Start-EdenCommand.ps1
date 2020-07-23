function Start-EdenCommand
{
    [CmdletBinding()]
    param(
        [String] $EdenCommand,
        $EdenEnvConfig,
        [String] $LoggingPrefix
    ) 
    Write-EdenBuildInfo "Starting the Eden command job: $EdenCommand." $LoggingPrefix
    $location = Get-Location
    $scriptRoot = $PSScriptRoot
    $job = Start-Job -Name "cj-$EdenCommand" -ScriptBlock {
        $EdenCommand = $args[0]
        $EdenEnvConfig = $args[1]
        $LoggingPrefix = $args[2]
        $VerbosePref = $args[3]
        $ScriptRoot = $args[4]
        $Location = $args[5]
        try {
            $VerbosePreference = $VerbosePref
            Write-Verbose $ScriptRoot
            Set-Location $Location
            Import-Module (Join-Path $ScriptRoot "../../Eden/Eden.psm1")
            . (Join-Path $ScriptRoot "./Invoke-EdenCommand.ps1")
            Write-EdenBuildInfo "Invoking the Eden command: $($EdenCommand)" $LoggingPrefix
            Invoke-EdenCommand -EdenCommand $EdenCommand -EdenEnvConfig $EdenEnvConfig -LoggingPrefix $LoggingPrefix    
        } catch {
            Write-EdenBuildError "Failed to start the Eden command ($EdenCommand)" $LoggingPrefix
            throw $_
        }
        $VerbosePreference = "Continue"
        Write-Host "OK"
    } -ArgumentList @($EdenCommand, $EdenEnvConfig, $LoggingPrefix, $VerbosePreference, $scriptRoot, $location)
    # } -ArgumentList @($EdenCommand, $EdenEnvConfig)
return $job
}