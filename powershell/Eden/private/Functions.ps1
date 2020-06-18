function Write-BuildInfo {
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '', Scope='Function')]
    [CmdletBinding()]
    param(
        [String]$message,
        [String]$loggingPrefix
        )  
    Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $($loggingPrefix): $message"  -ForegroundColor DarkCyan 
}
function Write-BuildError {
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '', Scope='Function')]
    [CmdletBinding()]
    param(
        [String]$message,
        [String]$loggingPrefix
    ) 
    Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $($loggingPrefix): $message" -ForegroundColor DarkRed 
}
function Start-Function
{
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '', Scope='Function')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [String]$FunctionLocation,
        [Parameter(Mandatory=$TRUE)]
        [Int32]$Port,
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix
    )
    
    Start-Job -Name "rt-Service" -ScriptBlock {
        $functionLocation = $args[0]
        $port = $args[1]
        $loggingPrefix = $args[2]
        $VerbosePreference = $args[3]

        . ./Functions.ps1
    
        Write-BuildInfo "Setting location to '$functionLocation'" $loggingPrefix
        Set-Location $functionLocation
        try {
            $command = "func host start -p $port"
            Invoke-BuildCommand $command "Running the function application." $loggingPrefix
        } 
        catch 
        {
            Write-BuildError "If you get errno: -4058, try this: https://github.com/Azure/azure-functions-core-tools/issues/1804#issuecomment-594990804" $loggingPrefix
            throw $_
        }
        Write-BuildInfo "The function app at '$functionLocation' is running." $loggingPrefix
    } -ArgumentList @($FunctionLocation, $Port, $LoggingPrefix, $VerbosePreference)
}

function Start-LocalTunnel
{
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '', Scope='Function')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [Int32]$Port,
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix
    )

    Start-Job -Name "rt-Tunnel" -ScriptBlock {
        $port = $args[0]
        $loggingPrefix = $args[1]

        . ./Functions.ps1

        if ($IsWindows) {
            ./ngrok.exe http http://localhost:$port -host-header=rewrite | Write-Verbose
        } else {
            ./ngrok http http://localhost:$port -host-header=rewrite | Write-Verbose
        }

        Write-BuildInfo "The service tunnel is up." $loggingPrefix
    } -ArgumentList @($Port, $LoggingPrefix)
}

function Get-PublicUrl
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [Int32]$Port,
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix
    )
    try {
        Write-BuildInfo "Calling the ngrok API to get the public url." $LoggingPrefix
        $response = Invoke-RestMethod -URI http://localhost:4040/api/tunnels
        $privateUrl = "http://localhost:$Port"
        $tunnel = $response.tunnels | Where-Object {
            $_.config.addr -like $privateUrl -and $_.proto -eq "https"
        } | Select-Object public_url
        $publicUrl = $tunnel.public_url
        if(![string]::IsNullOrEmpty($publicUrl)) {
            Write-BuildInfo "Found the public URL: '$publicUrl' for private URL: '$privateUrl'." $LoggingPrefix
            return $publicUrl
        } else {
            return ""
        }
    }
    catch {
        $message = $_.Exception.Message
        Write-BuildError "Failed to get the public url: '$message'." $loggingPrefix
        return ""
    }
}

function Get-HealthStatus
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [String]$PublicUrl,
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix
    )
    try {
        Write-BuildInfo "Checking API availability at: $PublicUrl/api/healthcheck?userId=developer98765@test.com" $LoggingPrefix
        $response = Invoke-RestMethod -URI "$PublicUrl/api/healthcheck?userId=developer98765@test.com"
        $status = $response.status
        if($status -eq 0) {
            Write-BuildInfo "Health check status successful." $LoggingPrefix
            return $TRUE
        } else {
            return $FALSE
        }
    } catch {
        $message = $_.Exception.Message
        Write-BuildError "Failed to execute health check: '$message'." $LoggingPrefix
        return $FALSE
    }
}

function Test-Automated
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [String]$SolutionName,
        [Parameter(Mandatory=$TRUE)]
        [String]$ServiceName,
        [Parameter(Mandatory=$TRUE)]
        [String]$AutomatedUrl,
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix,
        [Parameter()]
        [switch]$Continuous
    )
    $automatedTestJob = Start-Job -Name "rt-Automated" -ScriptBlock {
        $AutomatedUrl = $args[0]
        $Continuous = $args[1]
        $LoggingPrefix = $args[2]
        $VerbosePreference = $args[3]
        $SolutionName = $args[4]
        $ServiceName = $args[5]

        . ./Functions.ps1
    
        $Env:AutomatedUrl = $AutomatedUrl
        Write-BuildInfo "Running automated tests against '$AutomatedUrl'." $LoggingPrefix

        if ($Continuous)
        {
            Invoke-BuildCommand "dotnet watch --project ./../Service.Tests/$SolutionName.$ServiceName.Service.Tests.csproj test --filter TestCategory=Automated" "Running automated tests continuously." $LoggingPrefix
        }
        else
        {
            Invoke-BuildCommand "dotnet test ./../Service.Tests/$SolutionName.$ServiceName.Service.Tests.csproj --filter TestCategory=Automated" "Running automated tests once." $LoggingPrefix
            Write-BuildInfo "Finished running automated tests." $LoggingPrefix
        }
    } -ArgumentList @($AutomatedUrl, $Continuous, $LoggingPrefix, $VerbosePreference, $SolutionName, $ServiceName)
    return $automatedTestJob
}

function Connect-AzureServicePrincipal {
    [CmdletBinding()]
    param(
        [string] $loggingPrefix
    )

    $userId = $Env:UserId
    $password = $Env:Password
    $tenantId = $Env:TenantId

    Write-BuildInfo "Connecting to service principal: $userId on tenant: $tenantId" $loggingPrefix
    
    $pswd = ConvertTo-SecureString $password
    $pscredential = New-Object System.Management.Automation.PSCredential($userId, $pswd)
    $result = Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $tenantId | Write-Verbose
    if ($VerbosePreference -ne 'SilentlyContinue') { $result }
}