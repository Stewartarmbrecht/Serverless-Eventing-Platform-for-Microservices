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
    param([System.Collections.ArrayList]$log)
    $block = [scriptblock]::Create({
        param($Message, $LoggingPrefix)
        $logEntry = "$LoggingPrefix $Message"
        Write-Verbose $logEntry
        $log.Add($logEntry)
    })
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
        
        $logEntry = "$LoggingPrefix $EdenCommand $($EdenEnvConfig.SolutionName) $($EdenEnvConfig.ServiceName)"
        Write-Verbose $logEntry
        [Void]$Log.Add($logEntry)
        if ($ReturnValue) {
            return $ReturnValue
        }
        if ($ReturnValueSet) {
            if ($null -eq $script:callCount) { $script:callCount = 0 } else { $script:callCount++ }
            Write-Verbose "Call Count: $script:callCount"
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
        
        $logEntry = "$LoggingPrefix $EdenCommand $($EdenEnvConfig.SolutionName) $($EdenEnvConfig.ServiceName)"
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
        
        $message = "Mock: $EdenCommand job starting. $LoggingPrefix"
        [Void]$Log.Add($message)
        Write-Verbose $message

        # Execute the body of the job sequentially.
        $job = Start-ThreadJob {
            param(
                $EdenCommand,
                $VerbosePref
            )

            $VerbosePreference = $VerbosePref
            $message = "Mock: $($EdenCommand) job executing"
            Write-Verbose $message
            Start-Sleep -Milliseconds 2000
        } -ArgumentList @($EdenCommand, $VerbosePreference)
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
        
        $message = "Mock: $EdenCommand job starting. $LoggingPrefix"
        [Void]$Log.Add($message)
        Write-Verbose $message

        # Execute the body of the job sequentially.
        $job = Start-ThreadJob {
            param(
                $EdenCommand,
                $VerbosePref
            )
            
            $VerbosePreference = $VerbosePref
            $message = "Mock: $($EdenCommand) job executing"
            Write-Verbose $message
            throw "My Error!"
        } -ArgumentList @($EdenCommand, $VerbosePreference)
        return $job
    }).GetNewClosure()
    return $block
}
function Assert-Logs {
    param(
        [System.Collections.ArrayList] $Actual,
        [Array] $Expected
    )
    for ($i=0; $i -lt $Expected.Length; $i++) {
        if ($Expected[$i] -ne "!SKIP!") {
            $actualPrint
            foreach($entry in $Actual) {
                $actualPrint = "$actualPrint`"$entry`",`n"
            } 
            $Actual[$i] | Should -Be $Expected[$i] -Because "Exepcted the $i entry in log: `n$($actualPrint) `nto have a value of: `n'$($Expected[$i])' `nbut it was `n'$($Actual[$i])'"
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