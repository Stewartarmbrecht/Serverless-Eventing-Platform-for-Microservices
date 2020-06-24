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
            Write-BuildInfo "Health check status unsuccessful. Status: $status" $LoggingPrefix
            return $FALSE
        }
    } catch {
        $message = $_.Exception.Message
        Write-BuildError "Failed to execute health check: '$message'." $LoggingPrefix
        return $FALSE
    }
}