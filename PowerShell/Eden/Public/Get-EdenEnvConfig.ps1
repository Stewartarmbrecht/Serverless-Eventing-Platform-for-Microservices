function Get-EdenEnvConfig
{
    [CmdletBinding()]
    param(
        [String] $SolutionName,
        [String] $ServiceName,
        [Switch] $Prompt,
        [Switch] $Check
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
    $config.PublicUrlToLocalWebServer = ""
    $pwdSS = Get-EnvironmentVariable "$SolutionName.$ServiceName.ServicePrincipalPassword"
    if ($pwdSS) {
        $config.ServicePrincipalPassword = ConvertTo-SecureString $pwdSS
    }
    $config.TenantId = Get-EnvironmentVariable "$SolutionName.$ServiceName.TenantId"
    $config.DeveloperId = Get-EnvironmentVariable "$SolutionName.$ServiceName.DeveloperId"

    if ($Check)
    {
        $message = "The following Eden environment configuration values are missing: "
        $missing = New-Object -TypeName "System.Collections.ArrayList"

        $config.PSObject.Properties | ForEach-Object {
            if(!($_.Value) -and $_.Name -ne "PublicUrlToLocalWebServer") {
                $missing.Add($_.Name)
            }
        }

        if ($missing.Count -gt 0) {

            $first = $true

            $missing.Sort()
            $missing | ForEach-Object {
                if (!$first) {
                    $message = $message + ", " + $_
                } else {
                    $message = $message + $_
                    $first = $false
                }
            }
    
            Write-EdenBuildError $message "$SolutionName $ServiceName"
    
            throw $message    
        }
    }
    
    return $config

}
