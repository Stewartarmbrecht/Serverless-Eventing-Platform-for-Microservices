[CmdletBinding()]
param(
    $EdenEnvConfig,
    [String] $LoggingPrefix
)
try {
    Write-EdenBuildInfo "Calling the ngrok API to get the public url." $LoggingPrefix
    $response = Invoke-RestMethod -URI http://localhost:4040/api/tunnels
    $privateUrl = "http://localhost:7071"
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
