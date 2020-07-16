function Invoke-CommandStartLocalTunnel 
{
    [CmdletBinding()]
    param(
        [EdenEnvConfig]$EdenEnvConfig
    ) 

    if ($IsWindows) {
        ./../apps/ngrok.exe http http://localhost:7071 -host-header=rewrite
    } else {
        ./../apps/ngrok http http://localhost:7071 -host-header=rewrite
    }
    if ($LASTEXITCODE -ne 0) { throw "Using ngrok to create a local tunnel on port 7071 failed."}    
}