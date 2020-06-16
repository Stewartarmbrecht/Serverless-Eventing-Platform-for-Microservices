[CmdletBinding()]
param ()
try {
    while ($TRUE) {
        Write-Verbose "Test"
    }

} catch {
    Write-Verbose "Catch"

} finally {
    Write-Verbose "Finally"
}