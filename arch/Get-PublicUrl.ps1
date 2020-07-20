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
        Write-EdenBuildInfo "Calling the ngrok API to get the public url to port '$Port'." $LoggingPrefix
        $response = Invoke-RestMethod -URI http://localhost:4040/api/tunnels
        $privateUrl = "http://localhost:$Port"
        $tunnel = $response.tunnels | Where-Object {
            $_.config.addr -like $privateUrl -and $_.proto -eq "https"
        } | Select-Object public_url
        $publicUrl = $tunnel.public_url
        Write-EdenBuildInfo "Found the public URL: '$publicUrl' for private URL: '$privateUrl'." $LoggingPrefix
        return $publicUrl
    }
    catch {
        $message = $_.Exception.Message
        Write-EdenBuildError "Failed to get the public url: '$message'." $loggingPrefix
        return ""
    }
}