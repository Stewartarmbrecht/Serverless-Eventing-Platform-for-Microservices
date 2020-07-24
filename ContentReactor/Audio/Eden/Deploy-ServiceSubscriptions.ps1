[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)

    Write-EdenBuildInfo "Connecting to azure tenant using the following configuration:" $loggingPrefix

    Write-EdenBuildInfo "SolutionName       : $($EdenEnvConfig.SolutionName)" $LoggingPrefix
    Write-EdenBuildInfo "ServiceName        : $($EdenEnvConfig.ServiceName)" $LoggingPrefix
    Write-EdenBuildInfo "EnvironmentName    : $($EdenEnvConfig.EnvironmentName)" $LoggingPrefix
    Write-EdenBuildInfo "Region             : $($EdenEnvConfig.Region)" $LoggingPrefix
    Write-EdenBuildInfo "ServicePrincipalId : $($EdenEnvConfig.ServicePrincipalId)" $LoggingPrefix
    Write-EdenBuildInfo "TenantId           : $($EdenEnvConfig.TenantId)" $LoggingPrefix
    Write-EdenBuildInfo "DeveloperId        : $($EdenEnvConfig.DeveloperId)" $LoggingPrefix

    $pscredential = New-Object System.Management.Automation.PSCredential( `
        $EdenEnvConfig.ServicePrincipalId, `
        (ConvertTo-SecureString $EdenEnvConfig.ServicePrincipalPassword) `
    )
    Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $EdenEnvConfig.TenantId | Write-Verbose

    Write-EdenBuildInfo "Deploying the event grid subscriptions for the local functions app." $loggingPrefix

    $eventsResourceGroupName = "$($EdenEnvConfig.EnvironmentName)-events"
    $eventsSubscriptionDeploymentFile = "./Infrastructure/Subscriptions.json"
    $expireTime = Get-Date
    $expireTimeUtc = $expireTime.AddHours(1).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

    Write-EdenBuildInfo "Deploying to '$eventsResourceGroupName' events resource group." $loggingPrefix

    $result = New-AzResourceGroupDeployment `
        -ResourceGroupName $eventsResourceGroupName `
        -TemplateFile $eventsSubscriptionDeploymentFile `
        -InstanceName $EdenEnvConfig.EnvironmentName `
        -PublicUrlToLocalWebServer $EdenEnvConfig.PublicUrlToLocalWebServer `
        -UniqueDeveloperId $EdenEnvConfig.DeveloperId `
        -ExpireTimeUtc $expireTimeUtc
    if ($VerbosePreference -ne 'SilentlyContinue') { $result }
