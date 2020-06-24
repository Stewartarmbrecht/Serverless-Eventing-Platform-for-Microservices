function Invoke-CommandLocalTunnel 
{
    [CmdletBinding()]
    param(
        [String]$Port
    ) 

    if ($IsWindows) {
        ./../apps/ngrok.exe http http://localhost:$Port -host-header=rewrite
    } else {
        ./../apps/ngrok http http://localhost:$Port -host-header=rewrite
    }
    if ($LASTEXITCODE -ne 0) { throw "Using ngrok to create a local tunnel on port $Port failed."}    
}