function Invoke-CommandStartLocalService 
{
    [CmdletBinding()]
    param(
        [EdenEnvConfig]$EdenEnvConfig
    ) 
    func host start -p 7071
    if ($LASTEXITCODE -ne 0) { throw "Starting the function host threw an error."}
}