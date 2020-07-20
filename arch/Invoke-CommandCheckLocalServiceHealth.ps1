function Invoke-CommandCheckLocalServiceHealth
{
    [CmdletBinding()]
    param([EdenEnvConfig] $EdenEnvConfig)
    try {
        $response = Invoke-RestMethod -URI "$PublicUrl/api/healthcheck?userId=developer98765@test.com"
        $status = $response.status
        if($status -eq 0) {
            Write-EdenBuildInfo "Health check status successful." $LoggingPrefix
            return $TRUE
        } else {
            Write-EdenBuildInfo "Health check status unsuccessful. Status: $status" $LoggingPrefix
            return $FALSE
        }
    } catch {
        $message = $_.Exception.Message
        Write-EdenBuildError "Failed to execute health check: '$message'." $LoggingPrefix
        return $FALSE
    }
}