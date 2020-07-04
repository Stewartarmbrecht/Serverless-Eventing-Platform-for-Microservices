function Get-EdenEnvConfig
{
    [CmdletBinding()]
    param(
        [String] $SolutionName,
        [String] $ServiceName,
        [Switch] $Prompt
    )

    if ($Prompt) {
        Set-EdenEnvConfig -SolutionName $SolutionName -ServiceName $ServiceName -Check
    }

    $config = [EdenEnvConfig]::new()
    if (!$SolutionName) {
        $SolutionName = Get-SolutionName
    }
    if (!$ServiceName) {
        $ServiceName = Get-ServiceName
    }
    $config.SolutionName = $SolutionName
    $config.ServiceName = $ServiceName
    $config.EnvironmentName = Get-EnvironmentVariable "$SolutionName.$ServiceName.EnvironmentName"
    $config.Region = Get-EnvironmentVariable "$SolutionName.$ServiceName.Region"
    $config.ServicePrincipalId = Get-EnvironmentVariable "$SolutionName.$ServiceName.ServicePrincipalId"
    $pwdSS = Get-EnvironmentVariable "$SolutionName.$ServiceName.ServicePrincipalPassword"
    if ($pwdSS) {
        $config.ServicePrincipalPassword = ConvertTo-SecureString $pwdSS
    }
    $config.TenantId = Get-EnvironmentVariable "$SolutionName.$ServiceName.TenantId"
    $config.DeveloperId = Get-EnvironmentVariable "$SolutionName.$ServiceName.DeveloperId"
    
    return $config

}
