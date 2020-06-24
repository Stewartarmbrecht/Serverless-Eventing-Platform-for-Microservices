function Start-Application
{
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '', Scope='Function')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [String]$Location,
        [Parameter(Mandatory=$TRUE)]
        [Int32]$Port,
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix
    )
    
    $currentLocation = Get-Location
    
    try {
        Write-BuildInfo "Setting location to '$Location'." $LoggingPrefix
        Set-Location $Location
        Write-BuildInfo "Running the function application." $LoggingPrefix
        Invoke-CommandAppStart -Port $Port
    }
    catch {
        $message = $_.Exception.Message
        Write-BuildError "The job threw an exception: '$message'." $LoggingPrefix
        Write-BuildError "If you get errno: -4058, try this: https://github.com/Azure/azure-functions-core-tools/issues/1804#issuecomment-594990804" $LoggingPrefix
        Set-Location $currentLocation
        throw $_
    }
}