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

    Mock Get-SolutionName { "TestSolution" }
    Mock Get-ServiceName { "TestService" }
    Set-EdenServiceEnvVariables -Clear
    Set-EdenServiceEnvVariables -InstanceName "TestInstance" `
        -Region "TestRegion" `
        -TenantId "TestTenant" `
        -UserId "TestUserId" `
        -Password (ConvertTo-SecureString "TestPassword" -AsPlainText) `
        -UniqueDeveloperId "TestDevId" `
        -LocalHostingPort 9876
}
Export-ModuleMember -Function Set-TestEnvironment