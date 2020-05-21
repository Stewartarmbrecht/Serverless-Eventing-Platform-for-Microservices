$response = Invoke-RestMethod -URI http://localhost:4040/api/tunnels
$tunnel = $response.tunnels | Where-Object {
    $_.config.addr -like "http://localhost:5001" -and $_.proto -eq "https"
} | Select-Object public_url
$tunnel.public_url
