function Write-EdenBuildInfo {
    [CmdletBinding()]
    param(
        [String]$message,
        [String]$loggingPrefix
        )  
    Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $($loggingPrefix): $message"  -ForegroundColor DarkCyan 
}
function Write-EdenBuildError {
    [CmdletBinding()]
    param(
        [String]$message,
        [String]$loggingPrefix
    ) 
    Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $($loggingPrefix): $message" -ForegroundColor DarkRed 
}
function Invoke-BuildCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [String]$Command, 
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix, 
        [Parameter(Mandatory=$TRUE)]
        [String]$LogEntry,
        [switch]$ReturnResults,
        [switch]$Direct
    )
    Write-EdenBuildInfo $LogEntry $LoggingPrefix
    # Write-EdenBuildInfo "    In Direcotory: $(Get-Location)" $loggingPrefix
    try {
        # Write-EdenBuildInfo "Invoking command: $Command" $LoggingPrefix
        # $result | Write-Verbose
        # Write-Debug $result.ToString()
        if ($ReturnResults) {
            $result = (Invoke-Expression $Command) 2>&1
            $result | Write-Verbose
            if ($LASTEXITCODE -ne 0) { throw $result }
            return $result
        } else {
            if ($Direct) {
                Invoke-Expression $Command
                if ($LASTEXITCODE -ne 0) { throw $result }
            } else {
                Invoke-Expression $Command | Write-Verbose
                if ($LASTEXITCODE -ne 0) { throw $result }
            }
        }
    } catch {
        Write-EdenBuildError "Failed to execute command: $Command" $LoggingPrefix
        # Write-Error $_
        Write-EdenBuildError "Exiting due to error!" $LoggingPrefix
    }
}

function Connect-AzureServicePrincipal {
    [CmdletBinding()]
    param(
        [String]$loggingPrefix
    )

    $userName = $Env:UserName
    $password = $Env:Password
    $tenantId = $Env:TenantId
    $userId = $Env:UserId
    $subscriptionId = $Env:SubscriptionId

    Write-EdenBuildInfo "Connecting to Azure using User Id: $userId" $loggingPrefix

    $pswd = ConvertTo-SecureString $password
    $pscredential = New-Object System.Management.Automation.PSCredential($userId, $pswd)
    $result = Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $tenantId
    if ($VerbosePreference -ne 'SilentlyContinue') { $result }
}
