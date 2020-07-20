function Start-LocalTunnel
{
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '', Scope='Function')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [Int32]$Port,
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix
    )

    try
    {
        Write-EdenBuildInfo "Starting the local tunnel to port $Port." $LoggingPrefix

        Invoke-CommandLocalTunnel -Port $Port

        Write-EdenBuildInfo "The service tunnel has been shut down." $LoggingPrefix
    }
    catch
    {
        Write-EdenBuildError "Exception thrown while starting the local tunnel. Message: '$($_.Exception.Message)'" $LoggingPrefix
        throw $_ 
    }
}