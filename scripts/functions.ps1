function D([String]$value,[String]$loggingPrefix) { 
    Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $($loggingPrefix): $value"  -ForegroundColor DarkCyan 
}
function E([String]$value,[String]$loggingPrefix) { 
    Write-Host "$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S") $($loggingPrefix): $value"  -ForegroundColor DarkRed 
}
function ExecuteCommand([String]$command, [String]$loggingPrefix, [String]$logEntry) {
    D $logEntry $loggingPrefix
    # D "    In Direcotory: $(Get-Location)" $loggingPrefix
    $result = (iex $command) 2>&1
    if($lastExitCode -eq 2) {
        E "Failed to execute command: $command" $loggingPrefix
        $result
        E "Exiting due to error!" $loggingPrefix
        Exit
    }
}