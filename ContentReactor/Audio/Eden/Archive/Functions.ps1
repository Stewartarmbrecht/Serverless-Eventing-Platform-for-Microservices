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
        [String]$LoggingPrefix,
        [Switch]$Continuous
    )
    
    $job = Start-Job -Name "rt-Audio-Service" -ScriptBlock {
        $functionLocation = $args[0]
        $port = $args[1]
        $loggingPrefix = $args[2]
        $continuous = $args[3]

        . ./Functions.ps1
    
        Write-EdenBuildInfo "Setting location to '$functionLocation'" $loggingPrefix
        Set-Location $functionLocation
        try {
            if ($continuous) {
                $command = "func host start -p $port"    
            }
            $command = "func host start -p $port"
            Invoke-BuildCommand $command $loggingPrefix "Running the function application.  Continuous=$continuous" -Direct
        } catch {
            Write-EdenBuildError "If you get errno: -4058, try this: https://github.com/Azure/azure-functions-core-tools/issues/1804#issuecomment-594990804" $loggingPrefix
            throw
        }
        Write-EdenBuildInfo "The function app at '$functionLocation' is running." $loggingPrefix
    } -ArgumentList @($FunctionLocation, $Port, $LoggingPrefix, $Continuous)
    return $job
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

    Start-Job -Name "rt-Audio-Service-Tunnel" -ScriptBlock {
        $port = $args[0]
        $loggingPrefix = $args[1]

        . ./Functions.ps1

        if ($IsWindows) {
            Invoke-BuildCommand "./ngrok.exe http http://localhost:$port -host-header=rewrite | Write-Verbose" $loggingPrefix "Invoking ngrok.exe for windows."
        } else {
            ./ngrok http http://localhost:$port -host-header=rewrite | Write-Verbose
        }

        Write-EdenBuildInfo "The worker API tunnel is up." $loggingPrefix
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
            Write-EdenBuildInfo "Health check status: $status." $LoggingPrefix
            return $TRUE
        } else {
            Write-EdenBuildInfo "Health check status: $status." $LoggingPrefix
            return $FALSE
        }
    } catch {
        $message = $_.Exception.Message
        Write-EdenBuildError "Failed to execute health check: '$message'." $LoggingPrefix
        return $FALSE
    }
}

function Deploy-LocalSubscriptions
{
    [CmdletBinding()]
    param(  
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix,
        [Parameter(Mandatory=$True)]
        [String]$PublicUrlToLocalWebServer
    )

    $instanceName = $Env:InstanceName
    $uniqueDeveloperId = $Env:UniqueDeveloperId
    $eventsResourceGroupName = "$InstanceName-events"
    $eventsSubscriptionDeploymentFile = "./../Infrastructure/Subscriptions.local.json"

    Write-EdenBuildInfo "Deploying the web server subscriptions." $LoggingPrefix

    $expireTime = Get-Date
    $expireTimeUtc = $expireTime.AddHours(1).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

    Connect-AzureServicePrincipal $loggingPrefix

    Write-EdenBuildInfo "Deploying the event grid subscriptions for the local functions app." $loggingPrefix
    Write-EdenBuildInfo "Deploying to '$eventsResourceGroupName' events resource group." $loggingPrefix
    $result = New-AzResourceGroupDeployment `
        -ResourceGroupName $eventsResourceGroupName `
        -TemplateFile $eventsSubscriptionDeploymentFile `
        -InstanceName $instanceName `
        -PublicUrlToLocalWebServer $PublicUrlToLocalWebServer `
        -UniqueDeveloperId $uniqueDeveloperId `
        -ExpireTimeUtc $expireTimeUtc
    if ($VerbosePreference -ne 'SilentlyContinue') { $result }

    Write-EdenBuildInfo "Deployed the subscriptions." $LoggingPrefix
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
        Write-EdenBuildInfo "Running automated tests against '$AutomatedUrl'." $LoggingPrefix

        if ($Continuous)
        {
            # Write-EdenBuildInfo "Running automated tests continuously." $LoggingPrefix
            Invoke-BuildCommand "dotnet watch --project ./../Service.Tests/ContentReactor.Audio.Service.Tests.csproj test --filter TestCategory=Automated" $LoggingPrefix "Running automated tests continuously."
        }
        else
        {
            Invoke-BuildCommand "dotnet test ./../Service.Tests/ContentReactor.Audio.Service.Tests.csproj --filter TestCategory=Automated" $LoggingPrefix "Running automated tests once."
            Write-EdenBuildInfo "Finished running automated tests." $LoggingPrefix
        }
    } -ArgumentList @($AutomatedUrl, $Continuous, $LoggingPrefix, $VerbosePreference)
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
    Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $tenantId | Write-Verbose
}