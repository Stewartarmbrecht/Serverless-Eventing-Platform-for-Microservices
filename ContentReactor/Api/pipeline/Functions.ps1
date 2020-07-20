function Write-EdenBuildInfo {
    [CmdletBinding()]
    param(
        [String]$Message,
        [String]$LoggingPrefix
        )  
    Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $($LoggingPrefix): $Message"  -ForegroundColor DarkCyan 
}
function Write-EdenBuildError {
    [CmdletBinding()]
    param(
        [String]$Message,
        [String]$LoggingPrefix
    ) 
    Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $($LoggingPrefix): $Message" -ForegroundColor DarkRed 
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

    try 
    {
        $userName = $Env:UserName
        $password = $Env:Password
        $tenantId = $Env:TenantId
        $userId = $Env:UserId
        #$subscriptionId = $Env:SubscriptionId
    
        Write-EdenBuildInfo "Connecting to Azure using User Id: $userId" $loggingPrefix
    
        $pswd = ConvertTo-SecureString $password
        $pscredential = New-Object System.Management.Automation.PSCredential($userId, $pswd)
        $result = Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $tenantId #-Subscription $subscriptionId
        if ($VerbosePreference) {$result}
    }
    catch
    {
        Write-EdenBuildError 
        throw $_
    }
}

function Test-Automated
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [String]$AutomatedUrl,
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix,
        [Parameter()]
        [switch]$Continuous
    )
    $automatedTestJob = Start-Job -Name "rt-Audio-Automated" -ScriptBlock {
        $AutomatedUrl = $args[0]
        $Continuous = $args[1]
        $LoggingPrefix = $args[2]
        $VerbosePreference = $args[3]

        . ./Functions.ps1
    
        $Env:AutomatedUrl = $AutomatedUrl
        Write-EdenBuildInfo "This application does not have any automated tests yet.  Please add some!" $loggingPrefix
        # Write-EdenBuildInfo "Running automated tests against '$AutomatedUrl'." $LoggingPrefix

        # if ($Continuous)
        # {
        #     Write-EdenBuildInfo "Running automated tests continuously." $LoggingPrefix
        #     dotnet watch --project ./../tests/ContentReactor.Audio.Tests.csproj test --filter TestCategory=Automated
        # }
        # else
        # {
        #     Invoke-BuildCommand "dotnet test ./../tests/ContentReactor.Audio.Tests.csproj --filter TestCategory=Automated" $LoggingPrefix "Running automated tests once."
        #     Write-EdenBuildInfo "Finished running automated tests." $LoggingPrefix
        # }
    } -ArgumentList @($AutomatedUrl, $Continuous, $LoggingPrefix, $VerbosePreference)
    return $automatedTestJob
}


