function Write-BuildInfo {
    [CmdletBinding()]
    param(
        [String]$message,
        [String]$loggingPrefix
        )  
    Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $($loggingPrefix): $message"  -ForegroundColor DarkCyan 
}
function Write-BuildError {
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
    Write-BuildInfo $LogEntry $LoggingPrefix
    # Write-BuildInfo "    In Direcotory: $(Get-Location)" $loggingPrefix
    try {
        # Write-BuildInfo "Invoking command: $Command" $LoggingPrefix
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
        Write-BuildError "Failed to execute command: $Command" $LoggingPrefix
        # Write-Error $_
        Write-BuildError "Exiting due to error!" $LoggingPrefix
    }
}
function Start-Function
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [String]$FunctionType,
        [Parameter(Mandatory=$TRUE)]
        [String]$FunctionLocation,
        [Parameter(Mandatory=$TRUE)]
        [Int32]$Port,
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix
    )
    
    Start-Job -Name "rt-Audio-$FunctionType" -ScriptBlock {
        $functionLocation = $args[0]
        $port = $args[1]
        $loggingPrefix = $args[2]

        . ./Functions.ps1
    
        Write-BuildInfo "Setting location to '$functionLocation'" $loggingPrefix
        Set-Location $functionLocation
        Invoke-BuildCommand "func host start -p $port" $loggingPrefix "Running the API." -Direct
        Write-BuildInfo "The function app at '$functionLocation' is running." $loggingPrefix
    } -ArgumentList @($FunctionLocation, $Port, $LoggingPrefix)
}

function Start-LocalTunnel
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [String]$FunctionType,
        [Parameter(Mandatory=$TRUE)]
        [Int32]$Port,
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix
    )

    Start-Job -Name "rt-Audio-Tunnel-$FunctionType" -ScriptBlock {
        $port = $args[0]
        $loggingPrefix = $args[1]

        . ./Functions.ps1

        ./ngrok http http://localhost:$port -host-header=rewrite | Write-Verbose
        Write-BuildInfo "The worker API tunnel is up." $loggingPrefix
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
        Write-BuildInfo "Checking worker API availability at: $PublicUrl/api/healthcheck?userId=developer98765@test.com" $LoggingPrefix
        $response = Invoke-RestMethod -URI "$PublicUrl/api/healthcheck?userId=developer98765@test.com"
        $status = $response.status
        if($status -eq 0) {
            Write-BuildInfo "Health check status: $status." $LoggingPrefix
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

function Deploy-LocalSubscriptions
{
    [CmdletBinding()]
    param(  
        [Parameter(Mandatory=$TRUE)]
        [String] $InstanceName,
        [Parameter(Mandatory=$TRUE)]
        [String] $PublicUrlToLocalWebServer,
        [Parameter(Mandatory=$TRUE)]
        [String] $UserName,
        [Parameter(Mandatory=$TRUE)]
        [String] $Password,
        [Parameter(Mandatory=$TRUE)]
        [String] $TenantId,
        [Parameter(Mandatory=$TRUE)]
        [String] $UniqueDeveloperId,
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix
    )

    $eventsResourceGroupName = "$InstanceName-events"

    Write-BuildInfo "Deploying the web server subscriptions." $LoggingPrefix

    $command = "az login --service-principal --username $UserName --password $Password --tenant $TenantId"
    Invoke-BuildCommand $command $LoggingPrefix "Logging in the Azure CLI."

    $expireTime = Get-Date
    $expireTimeUtc = $expireTime.AddHours(1).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

    $command = @"
        az deployment group create ``
            -g $eventsResourceGroupName ``
            --template-file ./../infrastructure/eventGridSubscriptions.local.json ``
            --parameters ``
                uniqueResourcesystemName=$InstanceName ``
                publicUrlToLocalWebServer=$PublicUrlToLocalWebServer ``
                uniqueDeveloperId=$UniqueDeveloperId ``
                expireTimeUtc=$expireTimeUtc
"@
    Invoke-BuildCommand $command $LoggingPrefix "Deploying the event grid subscription."
    Write-BuildInfo "Deployed the subscriptions." $LoggingPrefix
}

function Test-EndToEnd
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix,
        [Parameter()]
        [switch]$Continuous
    )
    $e2eTestJob = Start-Job -Name "rt-Audio-EndToEndTesting" -ScriptBlock {
        $Continuous = $args[0]
        $LoggingPrefix = $args[1]

        . ./Functions.ps1
    
        if ($Continuous)
        {
            Write-BuildInfo "Running E2E tests continuously." $LoggingPrefix
            dotnet watch --project ./../tests/ContentReactor.Audio.Tests.csproj test --filter TestCategory=E2E
        }
        else
        {
            Invoke-BuildCommand "dotnet test ./../tests/ContentReactor.Audio.Tests.csproj --filter TestCategory=E2E" $LoggingPrefix "Running E2E tests once."
            Write-BuildInfo "Finished running E2E tests." $LoggingPrefix
        }
    } -ArgumentList @($Continuous, $LoggingPrefix)
    return $e2eTestJob
}