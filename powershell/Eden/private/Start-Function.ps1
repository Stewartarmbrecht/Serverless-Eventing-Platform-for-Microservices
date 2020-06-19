function Start-Function
{
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '', Scope='Function')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$TRUE)]
        [String]$FunctionLocation,
        [Parameter(Mandatory=$TRUE)]
        [Int32]$Port,
        [Parameter(Mandatory=$TRUE)]
        [String]$LoggingPrefix
    )
    
    Start-Job -Name "rt-Service" -ScriptBlock {
        $functionLocation = $args[0]
        $port = $args[1]
        $loggingPrefix = $args[2]
        $VerbosePreference = $args[3]

        . ./Functions.ps1
    
        Write-BuildInfo "Setting location to '$functionLocation'" $loggingPrefix
        Set-Location $functionLocation
        try {
            $command = "func host start -p $port"
            Invoke-BuildCommand $command "Running the function application." $loggingPrefix
        } 
        catch 
        {
            Write-BuildError "If you get errno: -4058, try this: https://github.com/Azure/azure-functions-core-tools/issues/1804#issuecomment-594990804" $loggingPrefix
            throw $_
        }
        Write-BuildInfo "The function app at '$functionLocation' is running." $loggingPrefix
    } -ArgumentList @($FunctionLocation, $Port, $LoggingPrefix, $VerbosePreference)
}