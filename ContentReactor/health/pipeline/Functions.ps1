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
        [String]$LogEntry,
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix, 
        [switch]$ReturnResults
    )
    Write-EdenBuildInfo $LogEntry $LoggingPrefix
    # Write-EdenBuildInfo "    In Direcotory: $(Get-Location)" $loggingPrefix
    try {
        if ($ReturnResults) 
        { 
            $result = (Invoke-Expression $Command) 2>&1
            $result | Write-Verbose
            if ($LASTEXITCODE -ne 0) { throw $result }
            return $result 
        }
        else
        {
            Invoke-Expression $Command | Write-Verbose
            if ($LASTEXITCODE -ne 0) { throw $result }
        }
    } 
    catch 
    {
        Write-EdenBuildError "Failed to execute command: $Command" $LoggingPrefix
        # Write-Error $_
        Write-EdenBuildError "Exiting due to error!" $LoggingPrefix
        throw $_
    }
}
function Start-Function
{
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
    
        Write-EdenBuildInfo "Setting location to '$functionLocation'" $loggingPrefix
        Set-Location $functionLocation
        try {
            $command = "func host start -p $port"
            Invoke-BuildCommand $command "Running the function application." $loggingPrefix
        } 
        catch 
        {
            Write-EdenBuildError "If you get errno: -4058, try this: https://github.com/Azure/azure-functions-core-tools/issues/1804#issuecomment-594990804" $loggingPrefix
            throw $_
        }
        Write-EdenBuildInfo "The function app at '$functionLocation' is running." $loggingPrefix
    } -ArgumentList @($FunctionLocation, $Port, $LoggingPrefix, $VerbosePreference)
}

function Start-LocalTunnel
{
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

        Write-EdenBuildInfo "The service tunnel is up." $loggingPrefix
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
        Write-EdenBuildInfo "Calling the ngrok API to get the public url." $LoggingPrefix
        $response = Invoke-RestMethod -URI http://localhost:4040/api/tunnels
        $privateUrl = "http://localhost:$Port"
        $tunnel = $response.tunnels | Where-Object {
            $_.config.addr -like $privateUrl -and $_.proto -eq "https"
        } | Select-Object public_url
        $publicUrl = $tunnel.public_url
        if(![string]::IsNullOrEmpty($publicUrl)) {
            Write-EdenBuildInfo "Found the public URL: '$publicUrl' for private URL: '$privateUrl'." $LoggingPrefix
            return $publicUrl
        } else {
            return ""
        }
    }
    catch {
        $message = $_.Exception.Message
        Write-EdenBuildError "Failed to get the public url: '$message'." $loggingPrefix
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
        Write-EdenBuildInfo "Checking API availability at: $PublicUrl/api/healthcheck?userId=developer98765@test.com" $LoggingPrefix
        $response = Invoke-RestMethod -URI "$PublicUrl/api/healthcheck?userId=developer98765@test.com"
        $status = $response.status
        if($status -eq 0) {
            Write-EdenBuildInfo "Health check status successful." $LoggingPrefix
            return $TRUE
        } else {
            return $FALSE
        }
    } catch {
        $message = $_.Exception.Message
        Write-EdenBuildError "Failed to execute health check: '$message'." $LoggingPrefix
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
        Write-EdenBuildInfo "Running automated tests against '$AutomatedUrl'." $LoggingPrefix

        if ($Continuous)
        {
            Invoke-BuildCommand "dotnet watch --project ./../Service.Tests/$SolutionName.$ServiceName.Service.Tests.csproj test --filter TestCategory=Automated" "Running automated tests continuously." $LoggingPrefix
        }
        else
        {
            Invoke-BuildCommand "dotnet test ./../Service.Tests/$SolutionName.$ServiceName.Service.Tests.csproj --filter TestCategory=Automated" "Running automated tests once." $LoggingPrefix
            Write-EdenBuildInfo "Finished running automated tests." $LoggingPrefix
        }
    } -ArgumentList @($AutomatedUrl, $Continuous, $LoggingPrefix, $VerbosePreference, $SolutionName, $ServiceName)
    return $automatedTestJob
}

function Connect-AzureServicePrincipal {
    [CmdletBinding()]
    param(
        [string] $logginPrefix
    )

    $userId = $Env:UserId
    $password = $Env:Password
    $tenantId = $Env:TenantId

    Write-EdenBuildInfo "Connecting to service principal: $userId on tenant: $tenantId" $loggingPrefix
    
    $pswd = ConvertTo-SecureString $password
    $pscredential = New-Object System.Management.Automation.PSCredential($userId, $pswd)
    $result = Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $tenantId | Write-Verbose
    if ($VerbosePreference -ne 'SilentlyContinue') { $result }
}