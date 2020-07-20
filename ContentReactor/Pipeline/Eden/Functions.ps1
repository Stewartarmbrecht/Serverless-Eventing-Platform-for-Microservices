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

function Start-EdenJob {
    [CmdletBinding()]
    param(
        [String] $JobName,
        [String] $Command
    )
    $instanceName = $Env:InstanceName
    $region = $Env:Region 
    $userName = $Env:UserName
    $password = $Env:Password 
    $tenantId = $Env:tenantId
    $uniqueDeveloperId = $Env:UniqueDeveloperId


    $job = Start-Job -Name "ej-$JobName" -ScriptBlock {

        . ./Functions.ps1

        $VerbosePreference = $args[0]
        $loggingPrefix = $args[1]
        $Env:InstanceName = $args[2]
        $Env:Region = $args[3]
        $Env:UserName = $args[4]
        $Env:Password = $args[5]
        $Env:tenantId = $args[6]
        $Env:UniqueDeveloperId = $args[7]
        $Command = $args[8]

        Write-EdenBuildInfo "Executing job command: $Command" $loggingPrefix 

        Invoke-Expression $Command
    
    } -ArgumentList @($VerbosePreference, $loggingPrefix, $instanceName, $region, $userName, $password, $tenantId, $uniqueDeveloperId, $Command)
}

function Connect-AzureServicePrincipal {
    [CmdletBinding()]
    param(
        [String] $loggingPrefix
    )

    $userName = $Env:UserName
    $password = $Env:Password
    $tenantId = $Env:TenantId
    $userId = $Env:UserId
    $subscriptionId = $Env:SubscriptionId

    if($null -eq $userId) {
        Write-EdenBuildInfo "Getting Azure context." $loggingPrefix
        $content = Get-AzContext
        if ($content) 
        {
            $needLogin = ([string]::IsNullOrEmpty($content.Account))
            if ($needLogin) {
                Write-EdenBuildInfo "Connecting to Azure." $loggingPrefix
                Connect-AzAccount
            }
        } 

        Write-EdenBuildInfo "Getting azure service principal for User Name: $userName." $loggingPrefix
        try {
            $sp = Get-AzAdServicePrincipal -DisplayName $userName
            Write-EdenBuildInfo "Found Azure Service Principal." $loggingPrefix
            Write-Verbose $sp
        } catch {
            Write-EdenBuildInfo "Error getting azure service principal for User Name: $userName." $loggingPrefix
            $sp = $null
        }

        if ($null -eq $sp) {
            Connect-AzAccount
            Write-EdenBuildInfo "Creating azure service principal for the subscription: $subscriptionId" $loggingPrefix
            # Import-Module Az.Resources # Imports the PSADPasswordCredential object
            $pswd = ConvertTo-SecureString $password
            $pswdText = ConvertFrom-SecureString $pswd -AsPlainText
            $credentials = New-Object Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential -Property @{ StartDate=Get-Date; EndDate=Get-Date -Year 2024; Password=$pswdText}
            $sp = New-AzAdServicePrincipal -DisplayName $userName -PasswordCredential $credentials
            Write-EdenBuildInfo "Waiting for azure service principal to be created for the subscription: $subscriptionId" $loggingPrefix
            Start-Sleep 10
            Write-EdenBuildInfo "Assigning service principal to Contributor role for the subscription: $subscriptionId" $loggingPrefix
            New-AzRoleAssignment -ApplicationId $sp.ApplicationId -RoleDefinitionName Contributor -Scope "/subscriptions/$subscriptionId"
            Write-EdenBuildInfo "Created azure service principal and assigned to Contributor role for the subscription: $subscriptionId." $loggingPrefix
            Write-Verbose $sp
        }
        
        $userId = $sp.ApplicationId
    }

    "User Id:"
    $userId.ToString()

    Start-Sleep 10

    $pscredential = New-Object System.Management.Automation.PSCredential($userId, $pswd)
    Write-EdenBuildInfo "Connecting to the service principal." $loggingPrefix
    Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $tenantId -Subscription $subscriptionId
}
