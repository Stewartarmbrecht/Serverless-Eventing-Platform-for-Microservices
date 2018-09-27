function D([String]$value,[String]$loggingPrefix,[String]$debug) { 
    Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $($loggingPrefix): $value"  -ForegroundColor DarkCyan 
}
function E([String]$value,[String]$loggingPrefix) { 
    Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $($loggingPrefix): $value"  -ForegroundColor DarkRed 
}
function ExecuteCommand([String]$command, [String]$loggingPrefix, [String]$logEntry) {
    D $logEntry $loggingPrefix
    # D "    In Direcotory: $(Get-Location)" $loggingPrefix
    $result = (Invoke-Expression $command) 2>&1
    $code = $lastExitCode
    if(($code -And $code -ne 0) -Or (!$code -And $code -ne 0 -And $error[0] -ne $null)) {
        E "Failed to execute command: $command" $loggingPrefix
        E "Command exited with a code of $code" $loggingPrefix
        E "Command exited with error: $($error[0])" $loggingPrefix
        $result
        E "Exiting due to error!" $loggingPrefix
        Exit
    } else {
        if($debug -eq "True") {
            $result
        }
        return $result
    }
}