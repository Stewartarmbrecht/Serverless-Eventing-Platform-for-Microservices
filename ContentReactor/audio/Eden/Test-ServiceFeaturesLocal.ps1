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

$pscredential = New-Object System.Management.Automation.PSCredential($EdenEnvConfig.ServicePrincipalId, $EdenEnvConfig.ServicePrincipalPassword)
Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $EdenEnvConfig.TenantId | Write-Verbose

$Env:AutomatedUrl = "http://localhost:7071/api/audio"

Write-EdenBuildInfo "Running the tests in the Serivce.Tests/ContentReactor.Audio.Service.Tests.csproj project that are tagged as Automated." $LoggingPrefix
dotnet test ./Service.Tests/ContentReactor.Audio.Service.Tests.csproj --filter TestCategory=Automated
