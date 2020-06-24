function Invoke-CommandAppStart 
{
    [CmdletBinding()]
    param(
        [Int]$Port
    ) 
    func host start -p $Port
    if ($LASTEXITCODE -ne 0) { throw "Starting the function host threw an error."}
}