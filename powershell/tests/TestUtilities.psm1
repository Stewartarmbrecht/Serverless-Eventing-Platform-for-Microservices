$Public  = @( Get-ChildItem -Path $PSScriptRoot\..\Eden\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\..\Eden\Private\*.ps1 -ErrorAction SilentlyContinue )

foreach($import in @($Public + $Private))
{
    try
    {
        . $import.fullname
    }
    catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

function Set-TestEnvironment {
    [CmdletBinding()]
    param(
    )

    Set-EdenEnvConfig -Clear
    Set-EdenEnvConfig `
        -EnvironmentName "TestEnvironment" `
        -Region "TestRegion" `
        -TenantId "TestTenant" `
        -ServicePrincipalId "TestServicePrincipalId" `
        -ServicePrincipalPassword (ConvertTo-SecureString "TestServicePrincipalPassword" -AsPlainText) `
        -DeveloperId "TestDevId"
}
function Get-MockWriteBuildInfoBlock {
    [CmdletBinding()]
    param([System.Collections.ArrayList]$Log)
    return {
        param($Message, $LoggingPrefix)
        $logEntry = "$LoggingPrefix $Message"
        Write-Verbose $logEntry
        $Log.Add($logEntry)
    }
}
Export-ModuleMember -Function Set-TestEnvironment, Get-MockWriteBuildInfoBlock