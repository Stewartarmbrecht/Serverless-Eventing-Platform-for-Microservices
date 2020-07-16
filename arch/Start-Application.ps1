function Start-Application
{
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '', Scope='Function')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [EdenEnvConfig] $EdenEnvConfig
    )
    
    $loggingPrefix = "$($edenEnvConfig.SolutionName) $($edenEnvConfig.ServiceName) Run $($edenEnvConfig.EnvironmentName)"

    try {
        Write-BuildInfo "Running the application." $LoggingPrefix
        Invoke-CommandAppStart -EdenEvnConfig $EdenEvnConfig
    }
    catch {
        $message = $_.Exception.Message
        Write-BuildError "The job threw an exception: '$message'." $LoggingPrefix
        Write-BuildError "If you get errno: -4058, try this: https://github.com/Azure/azure-functions-core-tools/issues/1804#issuecomment-594990804" $LoggingPrefix
        throw $_
    }
}