$Public  = @( Get-ChildItem -Path $PSScriptRoot\..\Eden\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\..\Eden\Private\*.ps1 -ErrorAction SilentlyContinue )

foreach($import in @($Public + $Private))
{
    try
    {
        . $import.fullname
    }
    catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

function Set-TestEnvironment {
    [CmdletBinding()]
    param(
    )

    Set-EdenEnvConfig -SolutionName "TestSolution" -ServiceName "TestService" -Clear
    Set-EdenEnvConfig `
        -SolutionName "TestSolution" `
        -ServiceName "TestService" `
        -EnvironmentName "TestEnvironment" `
        -Region "TestRegion" `
        -TenantId "TestTenantId" `
        -ServicePrincipalId "TestServicePrincipalId" `
        -ServicePrincipalPassword (ConvertTo-SecureString "TestServicePrincipalPassword" -AsPlainText) `
        -DeveloperId "TestDeveloperId"

    return Get-EdenEnvConfig
}
function Get-BuildInfoErrorBlock {
    param(
        [System.Collections.ArrayList]$Log,
        [int]$LogLimit = 0
    )
    $logCount = 0;
    $block = [scriptblock]::Create({
        param($Message, $LoggingPrefix)
        $VerbosePreference = "Continue"
        $logEntry = "$LoggingPrefix $Message"
        Write-Verbose $logEntry
        $Log.Add($logEntry)
        $script:logCount++
        Write-Verbose "Count: $script:logCount Limit: $LogLimit"
        if ($LogLimit -gt 0 -and $script:logCount -ge $LogLimit) {
            Write-Verbose "Stopping jobs!"
            Get-Job | Stop-Job
        }
    }).GetNewClosure()
    return $block
}
function Get-InvokeEdenCommandBlock {
    # not sure why this works but the $command and $log variables come from the calling scope.
    param(
        [System.Collections.ArrayList] $Log, 
        $ReturnValue,
        [Array]$ReturnValueSet
    )
    $block = [scriptblock]::Create({
        param(
            $EdenCommand, 
            $EdenEnvConfig, 
            $LoggingPrefix
        ) 
        $VerbosePreference = "Continue"
        $logEntry = "$LoggingPrefix Mock: $EdenCommand $($EdenEnvConfig.SolutionName) $($EdenEnvConfig.ServiceName)"
        Write-Verbose $logEntry
        [Void]$Log.Add($logEntry)
        if ($ReturnValue) {
            return $ReturnValue
        }
        if ($ReturnValueSet) {
            if ($null -eq $script:callCount) { $script:callCount = 0 } else { $script:callCount++ }
            #Write-Verbose "Call Count: $script:callCount"
            return $ReturnValueSet[$script:callCount]
        }
    }).GetNewClosure()
    return $block
}
function Get-InvokeEdenCommandBlockWithError {
    param(
        [System.Collections.ArrayList] $Log
    )

    $block = [scriptblock]::Create({
        param(
            $EdenCommand, 
            $EdenEnvConfig, 
            $LoggingPrefix
        ) 
        
        $VerbosePreference = "Continue"
        $logEntry = "$LoggingPrefix Mock With Error: $EdenCommand $($EdenEnvConfig.SolutionName) $($EdenEnvConfig.ServiceName)"
        Write-Verbose $logEntry
        [Void]$Log.Add($logEntry)
        throw "My Error!"
    }).GetNewClosure()
    return $block
}
function Get-StartEdenCommandBlock {
    param(
        [System.Collections.ArrayList] $Log
    )
    $block = [scriptblock]::Create({ 
        param (
            [String]$EdenCommand, 
            $EdenEnvConfig, 
            [String]$LoggingPrefix
        ) 
        
        $VerbosePreference = "Continue"
        $job = Start-ThreadJob {
            param(
                $EdenCommand,
                $VerbosePref,
                $LoggingPrefix
            )

            $VerbosePreference = $VerbosePref
            $message = "$LoggingPrefix Mock: $($EdenCommand) job executing"
            Write-Verbose $message
            While ($true) {}
        } -ArgumentList @($EdenCommand, $VerbosePreference, $LoggingPrefix)

        $message = "$LoggingPrefix Mock: $EdenCommand job starting."
        [Void]$Log.Add($message)
        Write-Verbose $message

        # Execute the body of the job sequentially.
        return $job
    }).GetNewClosure()
    return $block
}
function Get-StartEdenCommandBlockWithError {
    param(
        [System.Collections.ArrayList] $Log
    )
    $block = [scriptblock]::Create({ 
        param (
            [String]$EdenCommand, 
            $EdenEnvConfig, 
            [String]$LoggingPrefix
        ) 
        
        $VerbosePreference = "Continue"
        $message = "$LoggingPrefix Mock With Error: $EdenCommand job starting."
        [Void]$Log.Add($message)
        Write-Verbose $message

        # Execute the body of the job sequentially.
        $job = Start-ThreadJob {
            param(
                $EdenCommand,
                $VerbosePref,
                $LoggingPrefix
            )
            
            $VerbosePreference = $VerbosePref
            $message = "$LoggingPrefix Mock: $($EdenCommand) job executing"
            Write-Verbose $message
            #Start-Sleep -Milliseconds 200
            throw "My Error!"
        } -ArgumentList @($EdenCommand, $VerbosePreference, $LoggingPrefix)
        return $job
    }).GetNewClosure()
    return $block
}
function Assert-Logs {
    param(
        [System.Collections.ArrayList] $Actual,
        [Array] $Expected
    )
    for ($i=0; $i -lt $Expected.Count; $i++) {
        if ($Expected[$i] -ne "!SKIP!") {
            $actualPrint = ""
            foreach($entry in $Actual) {
                $actualPrint = "$actualPrint`"$entry`",`n"
            } 
            $Actual[$i] | Should -Be $Expected[$i] -Because "Exepcted the $i entry in log with $($Actual.Count) entries: `n$($actualPrint) `nto have a value of: `n'$($Expected[$i])' `nbut it was `n'$($Actual[$i])'"
        }
    }
}
Export-ModuleMember -Function `
    Set-TestEnvironment, `
    Get-BuildInfoErrorBlock, `
    Get-InvokeEdenCommandBlock, `
    Get-InvokeEdenCommandBlockWithError, `
    Get-StartEdenCommandBlock, `
    Get-StartEdenCommandBlockWithError, `
    Assert-Logs